const std = @import("std");
const Map = std.AutoArrayHashMapUnmanaged;
const Tile = @import("Tile.zig");

pub const ID = []const u8;

name: []const u8,
tiles: Map(Tile.ID, Tile)