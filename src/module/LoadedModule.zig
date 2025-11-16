const std = @import("std");
const List = std.ArrayListUnmanaged;
const umka = @import("umka");

const Tile = @import("Tile.zig");
const Allocator = std.mem.Allocator;

pub const ID = []const u8;
pub const Name = []const u8;

const Self = @This();

id: ID,
name: Name,
tiles: List(*Tile),
umka_instance: umka.Instance,

pub fn init(id: ID, name: Name) !Self {

    const umka_instance = try umka.Instance.alloc();

    return .{
        .id = id,
        .name = name,
        .tiles = .empty,
        .umka_instance = umka_instance
    };
}

pub fn deinit(self: *Self, allocator: Allocator) void {
    
    self.umka_instance.free();

    allocator.free(self.id);
    allocator.free(self.name);
    
    for(self.tiles.items) |tile| {
        tile.deinit(allocator);
        allocator.destroy(tile);
    }
    self.tiles.clearAndFree(allocator);
}