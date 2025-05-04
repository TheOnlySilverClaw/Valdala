const std = @import("std");
const glfw = @import("glfw");
const event = @import("event.zig");
const log = std.log.scoped(.controller);

const Allocator = std.mem.Allocator;
const Window = @import("Window.zig");

const Self = @This();

window: *Window,

pub fn init(window: *Window) Self {
    return .{
        .window = window
    };
}

pub fn registerWindowListeners(self: *Self) !void {
    
    try self.window.createKeyListener(.{
        .ptr = self,
        .call = &Self.onKey
    });
}

pub fn onKey(ptr: *anyopaque, key: glfw.Key, action: glfw.Action, modifiers: glfw.Modifiers) void {
    
    // TODO is there any better way?
    const self: *Self = @ptrCast(@alignCast(ptr));
    

    switch (key) {
        .escape => self.window.close(),
        else => log.debug("unbound key {s} {s} {s} {s}", .{
            @tagName(key),
            @tagName(action),
            if(modifiers.shift) "shift" else "",
            if(modifiers.alt) "alt" else ""
        })
    }
}

pub fn update(self: Self) void {
    _= self;
}