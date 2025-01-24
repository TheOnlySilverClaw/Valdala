const std = @import("std");
const log = std.log;
const input = @import("input");
const glfw = @import("glfw");

const Allocator = std.mem.Allocator;
const Window = input.Window;
const Controller = input.Controller;
const FontLoader = @import("graphics").FontLoader;

pub const Application = struct {

    allocator: Allocator,
    window: Window,


    pub fn init(allocator: Allocator) !Application {
        
        log.debug("initialize GLFW", .{});

        try glfw.initialize();
        glfw.window.hint(glfw.window.HintKey.ClientApi, glfw.window.no_api);

        return .{
            .allocator = allocator,
            .window = undefined
        };
    }

    pub fn deinit(self: Application) void {
        
        _ = self;
        glfw.terminate();
    }

    pub fn launch(self: Application) !void {

        log.info("Launch", .{});
        
        try @import("worldgen").generate(self.allocator);

    }
};