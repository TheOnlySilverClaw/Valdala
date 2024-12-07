const std = @import("std");
const webgpu = @import("webgpu");
const glfw = @import("glfw");

const log = std.log;
const input = glfw.input;
const binding = glfw.window;

const Surface = @import("../graphics/surface.zig").Surface;
const Renderer = @import("../graphics/renderer.zig").Renderer;
const Controller = @import("controller.zig").Controller;

pub const Window = struct {

    handle: binding.Window,
    surface: Surface,
    controller: *const Controller,
    renderer: *const Renderer,

    pub fn create(window: *Window, title: [*:0]const u8, width: u32, height: u32) !void {

        const handle = binding.create(width, height, title, null, null);
        
        const instance = webgpu.instance.create(null);

        const surface = try Surface.create(handle, instance);
        instance.release();

        window.handle = handle;
        window.surface = surface;

        handle.setUserPoiner(@ptrCast(window));
        _ = handle.setSizeCallback(&sizeCallback);
        _ = handle.setKeyCallback(&keyCallback);

        window.surface.resize(width, height);
    }


    fn sizeCallback(handle: binding.Window, new_width: i32, new_height: i32) callconv(.C) void {

        var window = @as(*Window, @ptrCast(@alignCast(handle.getUserPoiner())));
        var surface = &window.surface;
        surface.resize(@intCast(new_width), @intCast(new_height));
    }

    fn keyCallback(handle: binding.Window, key: input.Key, _: u32,
            action: input.Action, modifiers: input.Modifiers) callconv(.C) void {

        const window = @as(*const Window, @ptrCast(@alignCast(handle.getUserPoiner())));
        const controller = window.controller;
        controller.on_key(key, action, modifiers);
    }

    pub fn show(self: Window) !void {
        
        while (!self.handle.should_close()) {
            glfw.pollEvents();
            try self.renderer.render();
            std.Thread.sleep(std.time.ns_per_s / 60);
        }
    }

    pub fn destroy(self: Window) void {
        self.handle.destroy();
    }
};
