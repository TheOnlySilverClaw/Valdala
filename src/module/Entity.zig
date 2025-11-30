const std = @import("std");

const Allocator = std.mem.Allocator;
const Model = @import("gltf/Model.zig");

const Self = @This();

pub const ID = []const u8;
pub const Name = []const u8;

id: ID,
name: Name,
model: Model,
node: *const Model.Node,

pub fn deinit(self: *Self, allocator: Allocator) void {
    
    allocator.free(self.id);
    allocator.free(self.name);
    self.model.deinit();
}