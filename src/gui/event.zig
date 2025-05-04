const glfw = @import("glfw");

pub const KeyListener = struct {
    ptr: *anyopaque,
    call: *const fn(*anyopaque, glfw.Key, glfw.Action, glfw.Modifiers) void,

    pub fn onKey(listener: KeyListener, key: glfw.Key, action: glfw.Action, modifiers: glfw.Modifiers) void {
        listener.call(listener.ptr, key, action, modifiers);
    }
};