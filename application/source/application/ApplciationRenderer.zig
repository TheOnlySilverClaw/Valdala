const std = @import("std");
const glfw = @import("glfw");
const webgpu = @import("webgpu");
const graphics = @import("graphics");
const input = @import("input");

const Allocator = std.mem.Allocator;
const Window = input.Window;

const Self = @This();

allocator: Allocator,
window: Window,

pub fn init(allocator: Allocator) !Self {

    var window: Window = undefined;
    try window.create("Valdala", 1600, 1200);

    return .{
        .allocator = allocator,
        .window = window
    };
}