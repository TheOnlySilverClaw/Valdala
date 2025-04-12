const std = @import("std");
const webgpu = @import("webgpu");
const glfw = @import("glfw");

const log = std.log;

const Surface = @import("Surface.zig");
const Controller = @import("Controller.zig");

const Self = @This();

handle: *glfw.Window,
monitor: ?*glfw.Monitor,
surface: Surface,
controller: *const Controller,

pub fn create(window: *Self, title: [*:0]const u8, width: u32, height: u32) !void {


    const handle = glfw.Window.create(@intCast(width), @intCast(height), title, null, null)
        orelse return error.CreateWindow;
    
    const instance = webgpu.Instance.create(null);

    const surface = try Surface.create(handle, instance);
    instance.release();

    window.handle = handle;
    window.surface = surface;
    window.monitor = glfw.Monitor.getPrimary();

    handle.setUserPoiner(@ptrCast(window));
    _ = handle.setSizeCallback(&sizeCallback);
    _ = handle.setKeyCallback(&keyCallback);

    window.surface.resize(width, height);
}

fn sizeCallback(handle: *glfw.Window, width: i32, height: i32) callconv(.C) void {

    var window = getSelfPointer(handle);
    var surface = &window.surface;
    surface.resize(@intCast(width), @intCast(height));
}

fn keyCallback(handle: *glfw.Window, key: glfw.Key, scancode: glfw.ScanCode,
        action: glfw.Action, modifiers: glfw.Modifiers) callconv(.C) void {

    _ = scancode;
    const window = getSelfPointer(handle);
    const controller = window.controller;
    controller.onKey(key, action, modifiers);
}

pub fn shouldClose(self: Self) bool {
    return self.handle.shouldClose();
}

pub fn fullScreen(self: Self) void {
    
    if(self.monitor) |monitor| {
        if(monitor.getVideoMode()) |mode| {
            self.handle.setMonitor(monitor, 0, 0, mode.width, mode.height, mode.refresh_rate);
        }
    }
}

pub fn center(self: Self) void {

    if(self.monitor) |monitor| {
        if(monitor.getVideoMode()) |mode| {
            const x = (@as(u32, @intCast(mode.width)) - self.surface.width) / 2;
            const y = (@as(u32, @intCast(mode.height)) - self.surface.height) / 2;
            self.handle.setPosition(@intCast(x), @intCast(y));
        }
    }
}

pub fn destroy(self: Self) void {
    
    self.handle.destroy();
    self.surface.destroy();
}

fn getSelfPointer(handle: *glfw.Window) *Self {
    return @ptrCast(@alignCast(handle.getUserPoiner()));
}