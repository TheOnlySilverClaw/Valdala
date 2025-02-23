const std = @import("std");

const Allocator = std.mem.Allocator;
const Camera = @import("Camera.zig");
const Self = @This();

allocator: Allocator,
camera: *Camera,

pub fn init(allocator: Allocator, camera: *Camera) !Self {


    return .{
        .allocator = allocator,
        .camera = camera
    };
}