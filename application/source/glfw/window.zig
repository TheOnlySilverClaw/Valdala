const glfw = @import("glfw.zig");
const Monitor = @import("monitor.zig").Monitor;

pub fn create(width: u32, height: u32, title: [*:0] const u8) Window {
    return glfwCreateWindow(@intCast(width), @intCast(height), title, null, null);
}

pub const Window = *opaque {

    pub fn should_stay(window: Window) bool {
        return glfwWindowShouldClose(window) == glfw.FALSE;
    }
    
    pub const destroy = glfwDestroyWindow;
};


extern fn glfwCreateWindow(width: i32, height: i32, title: [*:0] const u8, shared: ?Window, monitor: ?Monitor) Window;

extern fn glfwWindowShouldClose(window: Window) c_int;

extern fn glfwDestroyWindow(window: Window) void;
