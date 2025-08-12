const std = @import("std");

const Allocator = std.mem.Allocator;

pub const ID = []const u8;
pub const Name = []const u8;

pub const Textures = struct {
    top: u8,
    bottom: u8,
    side: u8
};

const Self = @This();


id: ID,
name: Name,
textures: Textures,

pub fn deinit(self: Self, allocator: Allocator) void {
    
    allocator.free(self.id);
    allocator.free(self.name);
}