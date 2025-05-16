const std = @import("std");
const webgpu = @import("webgpu");

const Scene = @import("scene").Scene;

const Self = @This();


device: *webgpu.Device,

pub fn init(device: *webgpu.Device) !Self {
    return .{
        .device = device
    };
}

pub fn render(self: *Self, scene: *const Scene) !void {
     _ = self;
     _ = scene;
}

pub fn deinit(self: Self) void {
    _ = self;
}