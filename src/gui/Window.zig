const std = @import("std");
const glfw = @import("glfw");

const Self = @This();

handle: *glfw.Window,
monitor: ?*glfw.Monitor,

pub fn create(self: *Self, width: u32, height: u32, title: [*:0]const u8) !void {

    glfw.Window.hint(.ClientApi, glfw.no_api);

    self.monitor = glfw.Monitor.getPrimary();

    if(glfw.Window.create(@intCast(width), @intCast(height), title, null, null)) |handle| {
        self.handle = handle;
    } else {
        return error.CreateWindow;
    }
}

pub fn destroy(self: *Self) void {
    self.handle.destroy();
}

pub fn shouldClose(self: Self) bool {
    return self.handle.shouldClose();
}

pub fn update(self: Self) void {
    _ = self;
}