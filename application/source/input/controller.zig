const std = @import("std");
const glfw = @import("glfw");

const Window = @import("window.zig").Window;

const log = std.log;
const input = glfw.input;

const Key = input.Key;
const Action = input.Action;
const Modifiers = input.Modifiers;


pub const Controller = struct {

    window: ?*const Window,

    pub fn on_key(_: Controller, key: Key, action: Action, modifiers: Modifiers) void {
        log.debug("key {} action {s} shift: {} control: {}",
            .{ key, @tagName(action), modifiers.shift, modifiers.control});
    }
};