const std = @import("std");
const glfw = @import("glfw");
const gui = @import("gui");
const Scene = @import("scene").Scene;
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;

const Self = @This();


allocator: Allocator,
window: *gui.Window,
controller: *gui.Controller,
renderer: *graphics.GameRenderer,
scene: ?*const Scene,

pub fn init(allocator: Allocator) !Self {

    try glfw.initialize();

    const window = try allocator.create(gui.Window);
    window.* = gui.Window.init(allocator);

    const controller= try allocator.create(gui.Controller);
    controller.* = gui.Controller.init(window);
    try controller.registerWindowListeners();

    try window.create(1000, 800, "Valdala");

    const renderer = try allocator.create(graphics.GameRenderer);
    renderer.* = try graphics.GameRenderer.init(allocator, window.surface);

    return .{
        .allocator = allocator,
        .window = window,
        .controller = controller,
        .renderer = renderer,
        .scene = null
    };
}

pub fn deinit(self: Self) void {

    self.window.destroy();
    self.window.deinit();
    self.allocator.destroy(self.window);
    
    self.allocator.destroy(self.controller);
    
    self.renderer.deinit(self.allocator);
    self.allocator.destroy(self.renderer);

    glfw.terminate();
}

pub fn launch(self: *Self) !void {
    
    self.scene = undefined;

    while(!self.window.shouldClose()) {
        glfw.pollEvents();
        self.window.update();
        if(self.scene) |scene| {
            try self.renderer.renderScene(scene);
        }
    }
}