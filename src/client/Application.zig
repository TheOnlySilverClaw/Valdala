const std = @import("std");
const net = std.net;
const fs = std.fs;
const time = std.time;
const glfw = @import("glfw");
const gui = @import("gui");
const graphics = @import("graphics");
const asset = @import("asset");
const log = std.log.scoped(.client);

const Allocator = std.mem.Allocator;
const Atomic = std.atomic.Value;
const Thread = std.Thread;
const ModuleLoader = @import("module").Loader;
const Terrain = @import("terrain").Terrain;
const Scene = @import("scene").Scene;
const Game = @import("game").Game;
const TrueType = @import("TrueType");
const Font = graphics.Font;

const Self = @This();

allocator: Allocator,
window: *gui.Window,
controller: *gui.Controller,
module_loader: ModuleLoader,
fonts: []Font,

pub fn init(allocator: Allocator, directory: fs.Dir) !Self {

    try glfw.initialize();

    const window = try allocator.create(gui.Window);
    window.* = gui.Window.init(allocator);

    const controller= try allocator.create(gui.Controller);
    controller.* = gui.Controller.new();
    try controller.registerWindowListeners(window);

    const monitor = glfw.monitor.getPrimaryMonitor() orelse {
        log.err("Could not find primary monitor", .{});
        return error.MonitorUnavailable;
    };

    const video_mode = monitor.getVideoMode() orelse {
        log.err("Could not get video mode", .{});
        return error.VideoModeUnavailable;
    };

    const window_percentage: f32 = 0.6;
    const window_width: u32 = @intFromFloat(window_percentage * @as(f32, @floatFromInt(video_mode.width)));
    const window_height: u32 = @intFromFloat(window_percentage * @as(f32, @floatFromInt(video_mode.height)));
    try window.create(window_width, window_height,"Valdala");
    window.center();
    controller.window_size = .of(@floatFromInt(window_width), @floatFromInt(window_height));

    const tile_textures = graphics.TextureArray.create(8, 8, 64, window.surface.device, .{ .label = .sliced("tiles")});
    const entity_textures = graphics.TextureList.init(allocator, window.surface.device);

    const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    var module_loader = try ModuleLoader.init(allocator, module_directory, tile_textures, entity_textures);
    const module_id = try allocator.dupe(u8, "valdala");
    _ = try module_loader.loadModule(module_id);


    const font_source = asset.font.fira_code_regular[0..];
    var font = try Font.init(allocator, window.surface.device, font_source, 24, 255);
    try font.loadASCII();

    const fonts = try allocator.alloc(Font, 1);
    fonts[0] = font;

    return .{
        .allocator = allocator,
        .window = window,
        .controller = controller,
        .module_loader = module_loader,
        .fonts = fonts
    };
}

pub fn deinit(self: *Self) void {

    self.window.destroy();
    self.allocator.destroy(self.window);
    
    self.allocator.destroy(self.controller);
    
    self.module_loader.deinit();

    for(self.fonts) |*font| {
        font.deinit();
    }
    self.allocator.free(self.fonts);

    glfw.terminate();
}

pub fn launch(self: *Self) !void {
    
    const allocator = self.allocator;
    const surface = &self.window.surface;

    var game = try Game.init(allocator);
    defer game.deinit();
    
    var scene = try Scene.init(allocator, 3, surface.aspect);
    defer scene.deinit();
    
    const tile_textures = self.module_loader.tile_registry.texture_array;
    const entity_textures = self.module_loader.entity_registry.texture_list;
    var renderer = try graphics.GameRenderer.init(surface, tile_textures, entity_textures, self.fonts);

    var user_interface = try gui.UserInterface.init(allocator, surface, self.fonts);
    defer user_interface.deinit();

    const target_frame_time = time.ns_per_ms * 16;

    var timer = try time.Timer.start();
    var player = try game.world.createPlayer(.{
        .transform = .origin
    });
    player.transform.position.z = 15;

    var chunk_mesher = try @import("scene").ChunkMesher.init(allocator, surface.device, game.world.terrain.grid, self.module_loader.tile_registry);
    defer chunk_mesher.deinit(allocator);

    var chunk_mesher_exit: Atomic(bool) = .init(false);
    const chunk_mesher_thread = try std.Thread.spawn(.{ .allocator = allocator }, Scene.launchChunkMesher, .{ allocator, &chunk_mesher_exit, &chunk_mesher, &scene.chunk_in_queue, &scene.chunk_out_queue });

    var arena: std.heap.ArenaAllocator = .init(allocator);
    defer arena.deinit();

    var terrain = &game.world.terrain;

    const arena_allocator = arena.allocator();

    // TODO figure out where to put this
    const loaded_entity = self.module_loader.entity_registry.entities.items[2];
    const loaded_mesh = loaded_entity.mesh;
    var entity_mesh = try @import("scene").EntityMesh.init(allocator, surface.device, loaded_mesh.positions, loaded_mesh.textcoords.?, loaded_mesh.indices, loaded_mesh.color_texture);
    // chunk meshes are unique and need to be destroyed with their chunk
    // entity meshes are shared and need to be destroyed once per entity type
    // TODO figure out where
    defer entity_mesh.deinit();
    entity_mesh.transform.moveZ(10.0);
    entity_mesh.transform.moveX(-50.0);

    for(0..5) |i| {
        var copy = entity_mesh;
        const f: f32 = @floatFromInt(i);
        copy.transform.moveX(15.0 * f);
        copy.transform.rotateRoll(std.math.degreesToRadians(15) * f);
        copy.transform.scaleUniform(1 - 0.1 * f);
        try scene.entities.append(allocator, copy);
    }


    while(true) {
        defer _ = arena.reset(.retain_capacity);

        const delta = timer.lap();

        const input = self.controller.poll();
        if(input.window.close) {
            chunk_mesher_exit.store(true, .release);
            chunk_mesher_thread.join();
            break;
        }

        const camera_speed = 10; // in units per second
        const delta_seconds = @as(f32, @floatFromInt(delta)) / @as(f32, @floatFromInt(std.time.ns_per_s));

        const movement_in_world_space = input.movement.rotation.project(input.movement.direction.times(delta_seconds * camera_speed));
        player.transform.position = player.transform.position.add(movement_in_world_space);

        player.transform.rotation = .aroundAxis(.of(-1,0,0), std.math.pi);
        player.transform.rotateAround(.of(1,0,0), input.movement.rotation.pitch);
        player.transform.rotateAround(.of(0,0,1), input.movement.rotation.yaw);

        const game_updates = try game.update(arena_allocator, delta);

        scene.camera.aspect = self.window.surface.aspect;
        scene.camera.transform = player.transform;
        try scene.updateTerrain(game.world.terrain, game_updates.world.load, game_updates.world.unload);
        
        const tile_position = game.world.terrain.grid.getHexagon(player.transform.position);
        const chunk_position = @import("terrain").Chunk.tileToChunkPosition(tile_position);

        user_interface.frame_time = delta;
        user_interface.position = player.transform.position;
        user_interface.tile_position = tile_position;
        user_interface.chunk_position = chunk_position;
        user_interface.chunk_distance = scene.chunk_distance;
        user_interface.chunks_loaded = scene.chunks.size;
        user_interface.rotation = player.transform.rotation;
        user_interface.frame_memory_usage = arena.queryCapacity();

        const player_step_position = player.transform.position.subtract(.of(0, 0, 1.5 ));
        const player_step_tile_position = terrain.grid.getHexagon(player_step_position);
        const player_step_tile = terrain.getTile(player_step_tile_position);

        // TODO mayve check multiple?
        const player_hand_distance = terrain.grid.hexagon.width;
        // the rotation axis looks completely wrong
        const hand_vector = player.transform.rollAxis().times(1 + player_hand_distance);
        const player_hand_position = player.transform.position.add(hand_vector);
        const player_hand_tile_position = terrain.grid.getHexagon(player_hand_position);
        const player_hand_tile = terrain.getTile(player_hand_tile_position);
        
        if(player_step_tile) |tile| {
            const player_step_tile_data = self.module_loader.tile_registry.getTile(tile.index);
            user_interface.step_tile_name = player_step_tile_data.name;
        }

        if(player_hand_tile) |tile| {
            const player_hand_tile_data = self.module_loader.tile_registry.getTile(tile.index);
            user_interface.hand_tile_name = player_hand_tile_data.name;
        }

        try user_interface.update();

        try renderer.render(scene, user_interface.canvas);

        const frame_time = timer.read();

        if(target_frame_time > frame_time) {
            const sleep_time = target_frame_time - frame_time;
            Thread.sleep(sleep_time);
        }
    }

}