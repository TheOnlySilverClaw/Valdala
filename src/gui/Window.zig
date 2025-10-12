const std = @import("std");
const glfw = @import("glfw");
const webgpu = @import("webgpu");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const listeners = @import("listeners.zig");

pub const Error = error {
    Create
};

const Handle = glfw.window.Window;

const Self = @This();


allocator: Allocator,
handle: *Handle,
monitor: ?*glfw.monitor.Monitor,
key_listener: ?*listeners.KeyListener,
resize_listener: ?*listeners.ResizeListener,
close_listener: ?*listeners.CloseListener,
surface: *graphics.Surface,

pub fn init(allocator: Allocator) Self {
    return .{
        .allocator = allocator,
        .monitor = null,
        .key_listener = null,
        .resize_listener = null,
        .close_listener = null,
        .handle = undefined,
        .surface = undefined
    };
}

pub fn deinit(self: Self) void {

    self.allocator.destroy(self.surface);

    if(self.key_listener) |listener| {
        self.allocator.destroy(listener);
    }
    
    if(self.resize_listener) |listener| {
        self.allocator.destroy(listener);
    }

    if(self.close_listener) |listener| {
        self.allocator.destroy(listener);
    }
}

pub fn create(self: *Self, width: u32, height: u32, title: [*:0]const u8) !void {

    Handle.hint(.ClientApi, glfw.window.no_api);

    self.monitor = glfw.monitor.getPrimaryMonitor();

    if(Handle.create(@intCast(width), @intCast(height), title, null, null)) |handle| {
        self.handle = handle;
    } else {
        return Error.Create;
    }

    const instance = webgpu.instance.Instance.create(null);
    self.surface = try self.allocator.create(graphics.Surface);
    try self.surface.create(self.handle, instance);
    instance.release();
    self.surface.resize(width, height);

    self.handle.setUserPoiner(self);
    _ = self.handle.setKeyCallback(Self.onKey);
    _ = self.handle.setSizeCallback(Self.onResize);
    _ = self.handle.setCloseCallback(Self.onClose);
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

pub fn createKeyListener(self: *Self, listener: listeners.KeyListener) !void {

    const pointer = try self.allocator.create(listeners.KeyListener);
    pointer.* = listener;
    self.key_listener = pointer;
}

fn onKey(handle: *Handle, key: glfw.keyboard.Key, scancode: glfw.keyboard.ScanCode, action: glfw.input.Action, modifiers: glfw.input.Modifiers) callconv(.c) void {
    
    _ = scancode;

    const window = getSelfPointer(handle);
    if(window.key_listener) |listener| {
        listener.onKey(key, action, modifiers);
    }
}

pub fn createResizeListener(self: *Self, listener: listeners.ResizeListener) !void {

    const pointer = try self.allocator.create(listeners.ResizeListener);
    pointer.* = listener;
    self.resize_listener = pointer;
}

fn onResize(handle: *Handle, width: i32, height: i32) callconv(.c) void {
    
    const window = getSelfPointer(handle);
    
    const width_unsigned: u32 = @intCast(width);
    const height_unsigned: u32 = @intCast(height);
    
    window.surface.resize(width_unsigned, height_unsigned);

    if(window.resize_listener) |listener| {
        listener.onResize(width_unsigned, height_unsigned);
    }
}

pub fn createCloseListener(self: *Self, listener: listeners.CloseListener) !void {

    const pointer = try self.allocator.create(listeners.CloseListener);
    pointer.* = listener;
    self.close_listener = pointer;
}

fn onClose(handle: *Handle) callconv(.c) void {
    
    const window = getSelfPointer(handle);
    if(window.close_listener) |listener| {
        listener.onClose();
    }
}

fn getSelfPointer(handle: *Handle) *Self {
    return @ptrCast(@alignCast(handle.getUserPoiner()));
}

pub fn center(self: Self) void {

    if(self.monitor) |monitor| {
        if(monitor.getVideoMode()) |mode| {
            const window_size = self.handle.getSize();
            const x = @as(u32, @intCast(mode.width - window_size.width)) / 2;
            const y = @as(u32, @intCast(mode.height - window_size.height)) / 2;
            self.handle.setPosition(@intCast(x), @intCast(y));
        }
    }
}
