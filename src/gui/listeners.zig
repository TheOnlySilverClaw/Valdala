const glfw = @import("glfw");

pub const KeyListener = struct {
    ptr: *anyopaque,
    call: *const fn (*anyopaque, glfw.keyboard.Key, glfw.input.Action, glfw.keyboard.Modifiers) void,

    pub fn onKey(listener: KeyListener, key: glfw.keyboard.Key, action: glfw.input.Action, modifiers: glfw.keyboard.Modifiers) void {
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
