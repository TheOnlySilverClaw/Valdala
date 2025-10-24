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

    while(true) {

        const delta = timer.lap();

        const input = self.controller.poll();
        if(input.window.close) break;
        
        const player_direction = scene.camera.transform.rotation.rotate(input.movement.direction);
        scene.camera.transform.moveX(player_direction.x);
        scene.camera.transform.moveY(player_direction.y);
        scene.camera.transform.moveZ(player_direction.z);
        scene.camera.transform.rotatePitch(input.movement.rotation.pitch * 0.1);
        scene.camera.transform.rotateYaw(input.movement.rotation.yaw * 0.1);
        scene.camera.transform.rotateRoll(input.movement.rotation.roll * 0.1);

        try game.update(delta);
        
        const hex_position = game.world.terrain.grid.getHexagon(scene.camera.transform.position);

        const Chunk = @import("terrain").Chunk;
        const chunk_position = Chunk.Position {
            .north = @divFloor(hex_position.north, Chunk.layout.width),
            .south_east = @divFloor(hex_position.south_east, Chunk.layout.width),
            .height = 0
        };

        user_interface.frame_time = delta;
        user_interface.position = scene.camera.transform.position;
        user_interface.hex_position = hex_position;
        user_interface.chunk_position = chunk_position;
        user_interface.rotation = scene.camera.transform.rotation;

        try user_interface.update();

        try renderer.render(scene, user_interface.canvas);

        const frame_time = timer.read();

        if(target_frame_time > frame_time) {
            const sleep_time = target_frame_time - frame_time;
            Thread.sleep(sleep_time);
        }
    }

}