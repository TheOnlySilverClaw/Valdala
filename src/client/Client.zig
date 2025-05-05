const std = @import("std");
const glfw = @import("glfw");
const gui = @import("gui");
const Scene = @import("scene").Scene;

const Allocator = std.mem.Allocator;

const Self = @This();


allocator: Allocator,
window: *gui.Window,
controller: *gui.Controller,
scene: ?*Scene,

pub fn init(allocator: Allocator) !Self {

    try glfw.initialize();

    const window = try allocator.create(gui.Window);
    window.* = gui.Window.init(allocator);

    const controller= try allocator.create(gui.Controller);
    controller.* = gui.Controller.init(window);
    try controller.registerWindowListeners();

    try window.create(1000, 800, "Valdala");

    return .{
        .allocator = allocator,
        .window = window,
        .controller = controller,
        .scene = null
    };
}

pub fn deinit(self: Self) void {

    self.window.destroy();
    self.window.deinit();
    self.allocator.destroy(self.window);
    self.allocator.destroy(self.controller);

    glfw.terminate();
}

pub fn launch(self: Self) !void {
    
    while(!self.window.shouldClose()) {
        glfw.pollEvents();
        self.window.update();
    }
}