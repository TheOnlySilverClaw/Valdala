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

pub fn onKey(ptr: *anyopaque, key: glfw.Key, action: glfw.Action, modifiers: glfw.Modifiers) void {
    
    var self: *Self = castSelfPointer(ptr);
    var input = &self.input;

    switch (key) {
        .escape => input.window.close = true,
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
    
    glfw.pollEvents();

    const snapshot = self.input;
    self.input = Input.new();
    return snapshot;
}
