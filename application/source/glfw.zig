const FALSE = 0;
const TRUE = 1;

pub const Window = opaque {

    pub fn create(width: u32, height: u32, title: [*:0] const u8) *Window {
        return glfwCreateWindow(@intCast(width), @intCast(height), title, null, null);
    }

    pub fn should_stay(window: *Window) bool {
        return glfwWindowShouldClose(window) == FALSE;
    }
    
    pub const destroy = glfwDestroyWindow;
};

pub const Monitor = opaque {

};

const GlfwError = error {
    InitFailed
};

pub fn init() !void {
    if(glfwInit() == FALSE) {
        return GlfwError.InitFailed;
    }
}

pub const terminate = glfwTerminate;

pub const pollEvents = glfwPollEvents;



extern fn glfwInit() c_int;

extern fn glfwTerminate() void;

extern fn glfwPollEvents() void;

extern fn glfwCreateWindow(width: c_int, height: c_int, title: [*:0] const u8, shared: ?*Window, monitor: ?*Monitor) *Window;

extern fn glfwWindowShouldClose(window: *Window) c_int;

extern fn glfwDestroyWindow(window: *Window) void;