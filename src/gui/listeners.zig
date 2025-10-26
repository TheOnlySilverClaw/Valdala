const glfw = @import("glfw");

pub const KeyListener = struct {

    pub const none = KeyListener {
        .ptr = undefined,
        .call = ignore
    };

    fn ignore(listener: *anyopaque, key: glfw.keyboard.Key, action: glfw.input.Action, modifiers: glfw.input.Modifiers) void {
        _ = listener;
        _ = key;
        _ = action;
        _ = modifiers;
    }

    ptr: *anyopaque,
    call: *const fn (*anyopaque, glfw.keyboard.Key, glfw.input.Action, glfw.input.Modifiers) void,

    pub fn onKey(listener: KeyListener, key: glfw.keyboard.Key, action: glfw.input.Action, modifiers: glfw.input.Modifiers) void {
        listener.call(listener.ptr, key, action, modifiers);
    }
};

pub const ResizeListener = struct {

    pub const none = ResizeListener {
        .ptr = undefined,
        .call = ignore
    };

    fn ignore(listener: *anyopaque, width: u32, height: u32) void {
        _ = listener;
        _ = width;
        _ = height;
    }

    ptr: *anyopaque,
    call: *const fn (*anyopaque, width: u32, height: u32) void,

    pub fn onResize(listener: ResizeListener, width: u32, height: u32) void {
        listener.call(listener.ptr, width, height);
    }
};

pub const CloseListener = struct {
    
    pub const none = CloseListener {
        .ptr = undefined,
        .call = ignore
    };

    fn ignore(listener: *anyopaque) void {
        _ = listener;
    }
    
    ptr: *anyopaque,
    call: *const fn (*anyopaque) void,

    pub fn onClose(listener: CloseListener) void {
        listener.call(listener.ptr);
    }
};
