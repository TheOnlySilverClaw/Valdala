const glfw = @import("glfw");

pub const KeyListener = struct {
    ptr: *anyopaque,
    call: *const fn (*anyopaque, glfw.Key, glfw.Action, glfw.Modifiers) void,

    pub fn onKey(listener: KeyListener, key: glfw.Key, action: glfw.Action, modifiers: glfw.Modifiers) void {
        listener.call(listener.ptr, key, action, modifiers);
    }
};

pub const ResizeListener = struct {
    ptr: *anyopaque,
    call: *const fn (*anyopaque, width: u32, height: u32) void,

    pub fn onResize(listener: ResizeListener, width: u32, height: u32) void {
        listener.call(listener.ptr, width, height);
    }
};

pub const CloseListener = struct {
    ptr: *anyopaque,
    call: *const fn (*anyopaque) void,

    pub fn onClose(listener: CloseListener) void {
        listener.call(listener.ptr);
    }
};
