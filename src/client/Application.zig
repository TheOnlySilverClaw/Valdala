const std = @import("std");
const net = std.net;
const fs = std.fs;
const glfw = @import("glfw");
const gui = @import("gui");
const graphics = @import("graphics");
const log = std.log.scoped(.client);

const Allocator = std.mem.Allocator;
const Thread = std.Thread;
const ModuleLoader = @import("module").Loader;
const World = @import("world").World;
const Scene = @import("scene").Scene;
const Game = @import("game").Game;

const Self = @This();


allocator: Allocator,
window: *gui.Window,
controller: *gui.Controller,
module_loader: ModuleLoader,

pub fn init(allocator: Allocator, directory: fs.Dir) !Self {

    try glfw.initialize();

    const window = try allocator.create(gui.Window);
    window.* = gui.Window.init(allocator);

    const controller= try allocator.create(gui.Controller);
    controller.* = gui.Controller.new();
    try controller.registerWindowListeners(window);

    const monitor = glfw.Monitor.getPrimary() orelse {
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

    var tile_textures: graphics.TextureArray = undefined;
    tile_textures.create(8, 8, 64, window.surface.device, .{ .label = .sized("tiles")});

    const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    var module_loader = try ModuleLoader.init(allocator, module_directory, tile_textures);
    const module_id = try allocator.dupe(u8, "valdala");
    _ = try module_loader.loadModule(module_id);


    return .{
        .allocator = allocator,
        .window = window,
        .controller = controller,
        .module_loader = module_loader
    };
}

pub fn deinit(self: *Self) void {

    self.window.destroy();
    self.window.deinit();
    self.allocator.destroy(self.window);
    
    self.allocator.destroy(self.controller);
    
    self.module_loader.deinit();

    glfw.terminate();
}

pub fn launch(self: *Self) !void {
    
    var game = try Game.init(self.allocator);
    defer game.deinit();
    var scene = try Scene.init(self.allocator, 4, self.window.surface.aspect);
    defer scene.deinit();
    var renderer = try graphics.GameRenderer.init(self.allocator, self.window.surface, self.module_loader.tile_registry);

    while(true) {
        
        const input = self.controller.poll();
        if(input.window.close) break;

        try game.tick();
        try renderer.renderScene(scene);
    }

}