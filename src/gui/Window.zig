const std = @import("std");
const glfw = @import("glfw");
const event = @import("event.zig");
const glfw_wgpu = @import("glfw-wgpu");
const webgpu = @import("webgpu");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;


pub const Error = error {
    Create
};

const Self = @This();


allocator: Allocator,
handle: *glfw.Window,
monitor: ?*glfw.Monitor,
key_listener: ?*event.KeyListener,
surface: *graphics.Surface,

pub fn init(allocator: Allocator) Self {
    return .{
        .allocator = allocator,
        .monitor = null,
        .key_listener = null,
        .handle = undefined,
        .surface = undefined
    };
}

pub fn deinit(self: Self) void {

    self.allocator.destroy(self.surface);

    if(self.key_listener) |listener| {
        self.allocator.destroy(listener);
    }
}

pub fn create(self: *Self, width: u32, height: u32, title: [*:0]const u8) !void {

    glfw.Window.hint(.ClientApi, glfw.no_api);

    self.monitor = glfw.Monitor.getPrimary();

    if(glfw.Window.create(@intCast(width), @intCast(height), title, null, null)) |handle| {
        self.handle = handle;
    } else {
        return Error.Create;
    }

    const instance = webgpu.Instance.create(null);
    self.surface = try self.allocator.create(graphics.Surface);
    try self.surface.create(self.handle, instance);
    instance.release();
    self.surface.resize(width, height);

    self.handle.setUserPoiner(self);
    _ = self.handle.setKeyCallback(Self.onKey);
}

pub fn destroy(self: *Self) void {

    self.surface.destroy();
    self.handle.destroy();
}

pub fn shouldClose(self: Self) bool {
    return self.handle.shouldClose();
}

pub fn close(self: Self) void {
    self.handle.setShouldClose(true);
}

pub fn update(self: Self) void {
    _ = self;
}

pub fn createKeyListener(self: *Self, listener: event.KeyListener) !void {

    self.key_listener = try self.allocator.create(event.KeyListener);
    self.key_listener.?.* = listener;
}

pub fn onKey(handle: *glfw.Window, key: glfw.Key, scancode: glfw.ScanCode, action: glfw.Action, modifiers: glfw.Modifiers) callconv(.C) void {
    
    _ = scancode;

    const window = getSelfPointer(handle);
    if(window.key_listener) |listener| {
        listener.onKey(key, action, modifiers);
    }
}

fn getSelfPointer(handle: *glfw.Window) *Self {
    return @ptrCast(@alignCast(handle.getUserPoiner()));
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