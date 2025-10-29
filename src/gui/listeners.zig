const glfw = @import("glfw");
const algebra = @import("algebra");

pub const WindowingEvent = union(enum) {
    key: struct { key: glfw.keyboard.Key, action: glfw.input.Action, modifiers: glfw.input.Modifiers },
    resize: struct { width: u32, height: u32 },
    mouseMove: algebra.Vector2(f32),
    mouseButton: struct { button: glfw.mouse.Button, action: glfw.input.Action, modifiers: glfw.input.Modifiers },
    scroll: algebra.Vector2(f32),
    close,
};

pub const WindowingEventListner = struct {
    pub const none = WindowingEventListner{ .ptr = undefined, .call = ignore };

    fn ignore(listener: *anyopaque, event: WindowingEvent) void {
        _ = listener;
        _ = event;
    }

    ptr: *anyopaque,
    call: *const fn (*anyopaque, WindowingEvent) void,

    pub fn onEvent(listener: WindowingEventListner, event: WindowingEvent) void {
        listener.call(listener.ptr, event);
    }
};
