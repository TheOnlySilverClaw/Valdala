pub const window = @import("window.zig");
pub const native = @import("native.zig");

pub const FALSE = 0;
pub const TRUE = 1;

pub const Platform = enum (u32) {
    any = 0x00060000,
    win32 = 0x00060001,
    cocoa = 0x00060002,
    wayland = 0x00060003,
    x11 = 0x00060004,
    none = 0x00060005
};

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

pub fn getPlatform() Platform {
    return @enumFromInt(glfwGetPlatform());
}


extern fn glfwInit() u32;

extern fn glfwTerminate() void;

extern fn glfwPollEvents() void;

extern fn glfwGetTime() f64;

extern fn glfwSwapInterval(interval: u32) void;

extern fn glfwGetPlatform() u32;