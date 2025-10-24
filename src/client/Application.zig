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

    const tile_textures = graphics.TextureArray.create(8, 8, 64, window.surface.device, .{ .label = .sliced("tiles")});

    const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    var module_loader = try ModuleLoader.init(allocator, module_directory, tile_textures);
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
    self.window.deinit();
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
    const surface = self.window.surface;

    var game = try Game.init(allocator);
    defer game.deinit();
    
    var scene = try Scene.init(allocator, 1, surface.aspect);
    defer scene.deinit();
    
    const tile_textures = self.module_loader.tile_registry.texture_array;
    var renderer = try graphics.GameRenderer.init(surface, tile_textures, self.fonts);

    var user_interface = try gui.UserInterface.init(allocator, surface, self.fonts);
    defer user_interface.deinit();

    const target_frame_time = time.ns_per_ms * 16;

    var timer = try time.Timer.start();
    var player = try game.world.createPlayer(.{
        .transform = .origin
    });
    player.transform.position.z = 15;

    var chunk_mesher = @import("scene").ChunkMesher {
        .device = surface.device,
        .grid = game.world.terrain.grid,
        .tile_registry = self.module_loader.tile_registry,
        .vertex_count = 0
    };

    while(true) {

        const delta = timer.lap();

        const input = self.controller.poll();
        if(input.window.close) break;
        
        const player_direction = player.transform.rotation.rotate(input.movement.direction);
        player.transform.moveX(player_direction.x);
        player.transform.moveY(player_direction.y);
        player.transform.moveZ(player_direction.z);
        player.transform.rotatePitch(input.movement.rotation.pitch * 0.1);
        player.transform.rotateYaw(input.movement.rotation.yaw * 0.1);
        player.transform.rotateRoll(input.movement.rotation.roll * 0.1);

        try game.update(delta);

        scene.camera.transform = player.transform;
        try scene.updateTerrain(game.world.terrain, &chunk_mesher);
        
        const tile_position = game.world.terrain.grid.getHexagon(player.transform.position);
        const chunk_position = @import("terrain").Chunk.tileToChunkPosition(tile_position);

        user_interface.frame_time = delta;
        user_interface.position = player.transform.position;
        user_interface.tile_position = tile_position;
        user_interface.chunk_position = chunk_position;
        user_interface.rotation = player.transform.rotation;

        try user_interface.update();

        try renderer.render(scene, user_interface.canvas);

        const frame_time = timer.read();

        if(target_frame_time > frame_time) {
            const sleep_time = target_frame_time - frame_time;
            Thread.sleep(sleep_time);
        }
    }

}