const std = @import("std");
const log = std.log;
const input = @import("input");
const glfw = @import("glfw");
const grapics = @import("graphics");

const Allocator = std.mem.Allocator;
const Window = input.Window;
const Controller = input.Controller;


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
        
        var font = try grapics.Font.init(self.allocator, "fonts/FiraCode/FiraCode-Regular.ttf", 24);
        const color = grapics.Color(f32).rgb(1.0, 1.0, 1.0);

        try font.loadASCII();
        var image = try font.renderUTF8("Käsekuchen mit Öl und Streußeln :)", color);
        defer image.deinit(self.allocator);

        font.deinit();
    }
};