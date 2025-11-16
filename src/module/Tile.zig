const std = @import("std");
const umka = @import("umka");

const Allocator = std.mem.Allocator;
const Function = umka.Function;

pub const ID = []const u8;
pub const Name = []const u8;


pub const Textures = struct {
    top: u32,
    bottom: u32,
    side: u32
};

pub const Behavior = struct {
    step: ?Function
};

const Self = @This();


id: ID,
name: Name,
textures: Textures,
behavior: Behavior,

pub fn deinit(self: Self, allocator: Allocator) void {
    
    allocator.free(self.id);
    allocator.free(self.name);
}