const std = @import("std");
const glfw = @import("glfw");
const gui = @import("gui");

const Allocator = std.mem.Allocator;

const Self = @This();


allocator: Allocator,
window: *gui.Window,

pub fn init(allocator: Allocator) !Self {

    if(!glfw.initialize()) return error.InitializeGLFW;

    const window = try allocator.create(gui.Window);
    try window.create(1000, 800, "Valdala");

    return .{
        .allocator = allocator,
        .window = window
    };
}

pub fn deinit(self: Self) void {

    self.allocator.destroy(self.window);

    glfw.terminate();
}

pub fn launch(self: Self) !void {
    
    while(!self.window.shouldClose()) {
        glfw.pollEvents();
        self.window.update();
    }
}