pub const window = @import("window.zig");

pub const FALSE = 0;
pub const TRUE = 1;


const GlfwError = error {
    InitFailed
};

pub fn initialize() !void {
    if(glfwInit() == FALSE) {
        return GlfwError.InitFailed;
    }
}

pub const terminate = glfwTerminate;

pub const pollEvents = glfwPollEvents;

pub const time = glfwGetTime;

pub const swapInterval = glfwSwapInterval;



extern fn glfwInit() c_int;

extern fn glfwTerminate() void;

extern fn glfwPollEvents() void;

extern fn glfwGetTime() f64;

extern fn glfwSwapInterval(interval: c_int) void;
