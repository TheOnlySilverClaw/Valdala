const glfw = @import("module.zig");
const input = @import("input.zig");
const Monitor = @import("monitor.zig").Monitor;

// opaque structs currently cannot have functions atttached directly
pub fn windowHint(key: HintKey, value: i32) void {
    glfwWindowHint(@intFromEnum(key), value);
}

// opaque structs currently cannot have functions atttached directly
pub fn createWindow(width: u32, height: u32, title: [*:0] const u8, monitor: ?Monitor, share: ?Window) Window {
    return glfwCreateWindow(@intCast(width), @intCast(height), title, monitor, share);
}

pub const Window = *opaque {

    pub fn shouldClose(window: Window) bool {
        return glfwWindowShouldClose(window) == glfw.TRUE;
    }
    
    pub const destroy = glfwDestroyWindow;

    pub const getUserPoiner = glfwGetWindowUserPointer;

    pub const setUserPoiner = glfwSetWindowUserPointer;

    pub const setSizeCallback = glfwSetWindowSizeCallback;

    pub const setKeyCallback = glfwSetKeyCallback;

    pub const GetCocoaWindow = glfwGetCocoaWindow;

};

pub const no_api = 0;

pub const HintKey = enum (i32) {
    ClientApi = 0x00022001
};

const SizeCallback = fn(window: Window, width: i32, height: i32) callconv(.C) void;

const KeyCallback = fn(window: Window, key: input.Key, scancode: u32, action: input.Action, modifiers: input.Modifiers) callconv(.C) void;


extern fn glfwWindowHint(hint: i32, value: i32) void;

extern fn glfwCreateWindow(width: i32, height: i32, title: [*:0] const u8, monitor: ?Monitor, share: ?Window) Window;

extern fn glfwWindowShouldClose(window: Window) c_int;

extern fn glfwDestroyWindow(window: Window) void;

extern fn glfwGetWindowUserPointer(window: Window) ?*anyopaque;

extern fn glfwSetWindowUserPointer(window: Window, user_pointer: ?*const anyopaque) void;

extern fn glfwSetWindowSizeCallback(window: Window, callback: *const SizeCallback) *const SizeCallback;

extern fn glfwSetKeyCallback(window: Window, callback: *const KeyCallback) *const KeyCallback;

extern fn glfwGetCocoaWindow(window: Window) *anyopaque;
