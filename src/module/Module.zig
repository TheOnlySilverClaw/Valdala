const std = @import("std");
const List = std.ArrayListUnmanaged;
const Tile = @import("Tile.zig");

const ArenaAllocator = std.heap.ArenaAllocator;

pub const ID = []const u8;
pub const Name = []const u8;

const Self = @This();

arena: *ArenaAllocator,
id: ID,
name: Name,
tiles: List(*Tile),

pub fn init(arena: *ArenaAllocator, id: ID) Self {
    return .{
        .arena = arena,
        .id = id,
        .name = "",
        .tiles = .empty
    };
}

pub fn deinit(self: Self) void {
    self.arena.deinit();
}