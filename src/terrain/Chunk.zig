const std = @import("std");
const algebra = @import("algebra");
const coordinate = @import("coordinate");

const Allocator = std.mem.Allocator;
const Tile = @import("Tile.zig");

pub const TileOffset = coordinate.hexagon.Position(u16);

pub const layout = struct {
    pub const width = 64;
    pub const height = 16;
    pub const area = width * width;
    pub const volume = area * height;
};

pub const Position = coordinate.hexagon.Position(i64);

const Self = @This();

visible: bool,
tiles: []Tile,

pub fn init(allocator: Allocator) Allocator.Error!Self {

    const tiles = try allocator.alloc(Tile, layout.volume);
    const air = Tile { .index = 0 };
    @memset(tiles, air);

    return .{
        .visible = false,
        .tiles = tiles
    };
}

pub fn deinit(self: Self, allocator: Allocator) void {
    allocator.free(self.tiles);
}

pub fn dupe(self: Self, allocator: Allocator) !Self {
    return .{
        .visible = self.visible,
        .tiles = try allocator.dupe(Tile, self.tiles),
    };
}

pub fn getTile(self: Self, offset: TileOffset) Tile {
    return self.tiles[indexOf(offset)];
}

pub fn setTile(self: *Self, offset: TileOffset, tile: Tile) void {
    self.tiles[indexOf(offset)] = tile;
}

fn indexOf(offset: TileOffset) usize {
    return @as(usize, offset.height) * layout.area + offset.south_east * layout.width + offset.north;
}

// TODO  should this stay here?
pub fn tileToChunkPosition(position: Position) Position {
    return .{
        .north = @divFloor(position.north, layout.width),
        .south_east = @divFloor(position.south_east, layout.width),
        .height = @divFloor(position.height, layout.height)
    };
}

pub fn cornerToTilePosition(position: Position) Position {
    return .{
        .north = position.north * layout.width,
        .south_east = position.south_east * layout.width,
        .height = position.height * layout.height
    };
}