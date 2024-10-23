const glfw = @import("glfw.zig");
const input = @import("input.zig");
const Monitor = @import("monitor.zig").Monitor;


const KeyCallback = fn(window: Window, key: input.Key, scancode: u32, action: input.Action, modifiers: input.Modifiers) callconv(.C) void;


pub fn create(width: u32, height: u32, title: [*:0] const u8, monitor: ?Monitor, share: ?Window) Window {
    return glfwCreateWindow(@intCast(width), @intCast(height), title, monitor, share);
}

pub const Window = *opaque {

    pub fn should_close(window: Window) bool {
        return glfwWindowShouldClose(window) == glfw.TRUE;
    }
    
    pub const destroy = glfwDestroyWindow;

    pub const getUserPoiner = glfwGetWindowUserPointer;

    pub const setUserPoiner = glfwSetWindowUserPointer;

    pub const setKeyCallback = glfwSetKeyCallback;
};


extern fn glfwCreateWindow(width: i32, height: i32, title: [*:0] const u8, monitor: ?Monitor, share: ?Window) Window;

extern fn glfwWindowShouldClose(window: Window) c_int;

extern fn glfwDestroyWindow(window: Window) void;

extern fn glfwGetWindowUserPointer(window: Window) ?*const anyopaque;

extern fn glfwSetWindowUserPointer(window: Window, user_pointer: ?*const anyopaque) void;

extern fn glfwSetKeyCallback(window: Window, callback: *const KeyCallback) *const KeyCallback;