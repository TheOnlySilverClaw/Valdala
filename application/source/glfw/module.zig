const std = @import("std");

pub usingnamespace @import("input.zig");
pub usingnamespace @import("window.zig");
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

pub const Version = struct {
    major: u32,
    minor: u32,
    revision: u32,

    pub fn format(self: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.print("{d}.{d}.{d}", .{ self.major, self.minor, self.revision });
    }
};

const GlfwError = error {
    InitFailed
};

pub fn initialize() !void {
    if(glfwInit() == FALSE) {
        return GlfwError.InitFailed;
    }
}

pub fn getVersion() Version {

    var version: Version = undefined;
    glfwGetVersion(&version.major, &version.minor, &version.revision);
    return version;
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

extern fn glfwGetVersion(major: *u32, minor: *u32, revision: *u32) void;