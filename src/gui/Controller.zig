const std = @import("std");
const glfw = @import("glfw");
const algebra = @import("algebra");
const log = std.log.scoped(.controller);


const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Window = @import("Window.zig");
const Input = @import("Input.zig");
const listeners = @import("listeners.zig");

const Self = @This();

input: Input,

pub fn new() Self {
    return .{
        .input = Input.new()
    };
}

pub fn registerWindowListeners(self: *Self, window: *Window) !void {
    
    window.event_listener = .{
        .ptr = self,
        .call = &Self.onEvent
    };
}

fn onEvent(ptr: *anyopaque, event: listeners.WindowingEvent) void {
    var self: *Self = @ptrCast(@alignCast(ptr));
    switch (event) {
        .resize => |size| self.onResize(size.width, size.height),
        .close => self.onClose(),
        .key => |key| self.onKey(key.key ,key.action, key.modifiers),
        else => {}
    }
}

pub fn onKey(self: *Self, key: glfw.keyboard.Key, action: glfw.input.Action, modifiers: glfw.input.Modifiers) void {
    const input = &self.input;
    var window = &input.window;
    var direction = &input.movement.direction;
    var rotation = &input.movement.rotation;

    switch (key) {
        .escape => window.close = true,
        .w => direction.y = 1,
        .a => direction.x = -1,
        .s => direction.y = -1,
        .d => direction.x = 1,
        .e => direction.z = 1,
        .q => direction.z = -1,
        .i => rotation.pitch = 1,
        .k => rotation.pitch = -1,
        .o => rotation.yaw = 1,
        .u => rotation.yaw = -1,
        .l => rotation.roll = 1,
        .j => rotation.roll = -1,
        else => {
            log.debug("unbound key {s} {s} {s} {s}", .{
            @tagName(key),
            @tagName(action),
            if(modifiers.shift) "shift" else "",
            if(modifiers.alt) "alt" else ""});
            return;
        }
    }
}

pub fn onResize(self: *Self, width: u32, height: u32) void {
    self.input.window.resize = .{
        .size = .{
            .width = width,
            .height = height
        }
    };
}

pub fn onClose(self: *Self) void {
    self.input.window.close = true;
}

pub fn poll(self: *Self) Input {
    
    glfw.pollEvents();

    const snapshot = self.input;
    self.input = Input.new();
    return snapshot;
}
