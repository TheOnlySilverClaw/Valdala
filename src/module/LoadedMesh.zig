const std = @import("std");

const Allocator = std.mem.Allocator;

const Self = @This();


positions: []const f32,
indices: []const u16,

pub fn deinit(self: Self, allocator: Allocator) void {
    allocator.free(self.positions);
    allocator.free(self.indices);
}