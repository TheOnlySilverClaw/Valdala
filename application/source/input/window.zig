const std = @import("std");
const glfw = @import("glfw");

const log = std.log;
const input = glfw.input;
const binding = glfw.window;

const Controller = @import("controller.zig").Controller;


pub const Window = struct {

    handle: binding.Window,
    controller: *const Controller,

    pub fn create(title: [*:0]const u8, width: u32, height: u32, controller: *const Controller) Window {

        const handle = binding.create(width, height, title, null, null);
        
        const window = Window {
            .handle = handle,
            .controller = controller
        };

        handle.setUserPoiner(@ptrCast(&window));
        _ = handle.setKeyCallback(&keyCallback);

        return window;
    }

    fn keyCallback(handle: binding.Window, key: input.Key, _: u32,
            action: input.Action, modifiers: input.Modifiers) callconv(.C) void {

        const user_pointer = handle.getUserPoiner().?;
        const window = @as(*const Window, @ptrCast(@alignCast(user_pointer)));
        const controller = window.controller;
        controller.on_key(key, action, modifiers);
    }

    pub fn show(self: Window) void {
        
        while (!self.handle.should_close()) {
            glfw.pollEvents();
            std.Thread.sleep(10 * std.time.ns_per_s / 60);
        }
    }

    pub fn destroy(self: Window) void {
        self.handle.destroy();
    }
};
