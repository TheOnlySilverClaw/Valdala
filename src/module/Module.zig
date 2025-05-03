const std = @import("std");
const List = std.ArrayListUnmanaged;
const Tile = @import("Tile.zig");

pub const ID = []const u8;
pub const Name = []const u8;

id: ID,
name: Name,
tiles: List(*Tile)