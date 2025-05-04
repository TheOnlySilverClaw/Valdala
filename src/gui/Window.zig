const std = @import("std");
const glfw = @import("glfw");
const event = @import("event.zig");

const Allocator = std.mem.Allocator;

pub const Error = error {
    Create
};

const Self = @This();


allocator: Allocator,
handle: *glfw.Window,
monitor: ?*glfw.Monitor,
key_listener: ?*event.KeyListener,

pub fn init(allocator: Allocator) Self {
    return .{
        .allocator = allocator,
        .handle = undefined,
        .monitor = null,
        .key_listener = null
    };
}

pub fn deinit(self: Self) void {
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

    self.handle.setUserPoiner(self);
    _ = self.handle.setKeyCallback(Self.onKey);
}

pub fn destroy(self: *Self) void {
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