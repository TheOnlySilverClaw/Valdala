const algebra = @import("algebra");
const coordinate = @import("coordinate");

const Vector = algebra.Vector3(f32);
const TilePosition = coordinate.Position(i64);
const Tile = @import("Tile.zig");

const Self = @This();

pub const Layout = struct {
    pub const width = 64;
    pub const height = 16;
    pub const area = width * width;
    pub const volume = area * height;
};

pub const TileOffset = struct {
    north: u6,
    south_east: u6,
    height: u4
};

position: Vector,
tiles: [Layout.volume]Tile,

pub fn getTile(self: Self, position: TileOffset) Tile {
    const index = @as(usize, @intCast(position.north))
        + @as(usize, @intCast(position.south_east)) * Layout.width
        + @as(usize, @intCast(position.height)) * Layout.area;
    return self.tiles[index];
}
