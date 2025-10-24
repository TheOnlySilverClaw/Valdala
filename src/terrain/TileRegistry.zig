const std = @import("std");

const Allocator = std.mem.Allocator;
const Tile = @import("Tile.zig");
const List = std.ArrayListUnmanaged;

pub const Error = error {
    Full
};

pub const Index = u16;

const Self = @This();


allocator: Allocator,
tiles: List(*Tile),

pub fn init(allocator: Allocator) Self {
    return .{
        .allocator = allocator,
        .tiles = List(*Tile).empty
    };
}

pub fn deinit(self: Self) void {
    self.tiles.clearAndFree(self.allocator);
}

pub fn register(self: Self, tile: *Tile) !Tile.Index {
    // TODO check for duplicates
    if(self.tiles.len >= std.math.maxInt(Index)) return Error.Full;
    try self.tiles.append(self.allocator, tile);
    return @intCast(self.tiles.len);
}

