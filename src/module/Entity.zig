const std = @import("std");

const Allocator = std.mem.Allocator;

pub const Model = @import("gltf/Model.zig");
pub const ID = []const u8;
pub const Name = []const u8;

const Self = @This();

id: ID,
name: Name,
model: Model,
node: *const Model.Node,

pub fn deinit(self: *Self, allocator: Allocator) void {
    
    allocator.free(self.id);
    allocator.free(self.name);
    self.model.deinit();
}