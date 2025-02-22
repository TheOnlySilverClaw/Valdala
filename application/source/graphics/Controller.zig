const std = @import("std");
const glfw = @import("glfw");

const Window = @import("Window.zig");

const log = std.log;

const Self = @This();

window: ?*const Window,

pub fn onKey(_: Self, key: glfw.Key, action: glfw.Action, modifiers: glfw.Modifiers) void {
    log.debug("key {} action {s} shift: {} control: {}",
        .{ key, @tagName(action), modifiers.shift, modifiers.control});
}