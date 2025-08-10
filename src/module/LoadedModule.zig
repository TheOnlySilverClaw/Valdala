const std = @import("std");
const List = std.ArrayListUnmanaged;
const Tile = @import("Tile.zig");

const Allocator = std.mem.Allocator;

pub const ID = []const u8;
pub const Name = []const u8;

const Self = @This();

id: ID,
name: Name,
tiles: List(*Tile),

pub fn init(id: ID, name: Name) Self {
    return .{
        .id = id,
        .name = name,
        .tiles = .empty
    };
}

pub fn deinit(self: *Self, allocator: Allocator) void {
    
    allocator.free(self.id);
    allocator.free(self.name);
    
    for(self.tiles.items) |tile| {
        tile.deinit(allocator);
        allocator.destroy(tile);
    }
    self.tiles.clearAndFree(allocator);
}