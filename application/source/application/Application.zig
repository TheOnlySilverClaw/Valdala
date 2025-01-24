const std = @import("std");
const log = std.log;
const input = @import("input");
const glfw = @import("glfw");

const Allocator = std.mem.Allocator;
const Window = input.Window;
const Controller = input.Controller;
const FontLoader = @import("graphics").FontLoader;

const Self = @This();

allocator: Allocator,
window: Window,


pub fn init(allocator: Allocator) !Self {
    
    log.debug("initialize GLFW", .{});

    try glfw.initialize();
    glfw.window.hint(glfw.window.HintKey.ClientApi, glfw.window.no_api);

    return .{
        .allocator = allocator,
        .window = undefined
    };
}

pub fn deinit(self: Self) void {
    
    _ = self;
    glfw.terminate();
}

pub fn launch(self: Self) !void {

    log.info("Launch", .{});
    
    try @import("worldgen").generate(self.allocator);

}

