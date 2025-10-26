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
key_listener: listeners.KeyListener,
resize_listener: listeners.ResizeListener,
close_listener: listeners.CloseListener,
surface: graphics.Surface,

pub fn init(allocator: Allocator) Self {
    return .{
        .allocator = allocator,
        .monitor = null,
        .key_listener = .none,
        .resize_listener = .none,
        .close_listener = .none,
        .handle = undefined,
        .surface = undefined
    };
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
    defer instance.release();
    
    try self.surface.create(self.handle, instance);
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

fn onKey(handle: *Handle, key: glfw.keyboard.Key, scancode: glfw.keyboard.ScanCode, action: glfw.input.Action, modifiers: glfw.input.Modifiers) callconv(.c) void {
    
    _ = scancode;

    const window = getSelfPointer(handle);
    window.key_listener.onKey(key, action, modifiers);
}

fn onResize(handle: *Handle, width: i32, height: i32) callconv(.c) void {
    
    const window = getSelfPointer(handle);
    
    const width_unsigned: u32 = @intCast(width);
    const height_unsigned: u32 = @intCast(height);
    
    window.surface.resize(width_unsigned, height_unsigned);
    window.resize_listener.onResize(width_unsigned, height_unsigned);
}

fn onClose(handle: *Handle) callconv(.c) void {
    
    const window = getSelfPointer(handle);
    window.close_listener.onClose();
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
