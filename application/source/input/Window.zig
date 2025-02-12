const std = @import("std");
const webgpu = @import("webgpu");
const glfw = @import("glfw");

const log = std.log;
const graphics = @import("graphics");

const Surface = graphics.Surface;
const Renderer = graphics.Renderer;
const Controller = @import("Controller.zig");

const Self = @This();

handle: glfw.Window,
surface: Surface,
controller: *const Controller,
renderer: *const Renderer,

pub fn create(window: *Self, title: [*:0]const u8, width: u32, height: u32) !void {

    const handle = glfw.createWindow(width, height, title, null, null);
    
    const instance = webgpu.createInstance(null);

    const surface = try Surface.create(handle, instance);
    instance.release();

    window.handle = handle;
    window.surface = surface;

    handle.setUserPoiner(@ptrCast(window));
    _ = handle.setSizeCallback(&sizeCallback);
    _ = handle.setKeyCallback(&keyCallback);

    window.surface.resize(width, height);
}


fn sizeCallback(handle: glfw.Window, width: i32, height: i32) callconv(.C) void {

    var window = getSelfPointer(handle);
    var surface = &window.surface;
    surface.resize(@intCast(width), @intCast(height));
}

fn keyCallback(handle: glfw.Window, key: glfw.Key, _: u32,
        action: glfw.Action, modifiers: glfw.Modifiers) callconv(.C) void {

    const window = getSelfPointer(handle);
    const controller = window.controller;
    controller.onKey(key, action, modifiers);
}

pub fn destroy(self: Self) void {
    self.handle.destroy();
}

fn getSelfPointer(handle: glfw.Window) *Self {
    return @ptrCast(@alignCast(handle.getUserPoiner()));
}