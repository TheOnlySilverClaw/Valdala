const std = @import("std");
const glfw = @import("glfw");
const algebra = @import("algebra");
const log = std.log.scoped(.controller);


const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Window = @import("Window.zig");
const Input = @import("Input.zig");

const Self = @This();

input: Input,

pub fn new() Self {
    return .{
        .input = Input.new()
    };
}

pub fn registerWindowListeners(self: *Self, window: *Window) !void {
    
    try window.createKeyListener(.{
        .ptr = self,
        .call = &Self.onKey
    });

    try window.createResizeListener(.{
        .ptr = self,
        .call = &Self.onResize
    });

    try window.createCloseListener(.{
        .ptr = self,
        .call = &Self.onClose
    });
}

pub fn onKey(ptr: *anyopaque, key: glfw.keyboard.Key, action: glfw.input.Action, modifiers: glfw.keyboard.Modifiers) void {
    
    var self: *Self = castSelfPointer(ptr);
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

pub fn onResize(ptr: *anyopaque, width: u32, height: u32) void {

    var self: *Self = @ptrCast(@alignCast(ptr));
    self.input.window.resize = .{
        .size = .{
            .width = width,
            .height = height
        }
    };
}

pub fn onClose(ptr: *anyopaque) void {

    var self: *Self = castSelfPointer(ptr);
    self.input.window.close = true;
}

fn castSelfPointer(ptr: *anyopaque) *Self {
    return @ptrCast(@alignCast(ptr));
}

pub fn poll(self: *Self) Input {
    
    glfw.system.pollEvents();

    const snapshot = self.input;
    self.input = Input.new();
    return snapshot;
}
