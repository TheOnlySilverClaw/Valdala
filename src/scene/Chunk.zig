const std = @import("std");
const algebra = @import("algebra");
const coordinate = @import("coordinate");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const Vector = algebra.Vector3(f32);
const TilePosition = coordinate.Position(i64);
const Tile = @import("Tile.zig");
const Mesh = graphics.ChunkMesh;

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
mesh: ?*const Mesh,
tiles: [Layout.volume]Tile,

pub fn init(position: Vector) Self {
    return .{
        .position = position,
        .mesh = null,
        .tiles = .{ Tile.empty } ** Layout.volume
    };
}

pub fn deinit(self: Self, allocator: Allocator) void {
    
    if(self.mesh) |mesh| {
        mesh.deinit();
        allocator.destroy(mesh);
    }
}

pub fn getTile(self: Self, position: TileOffset) Tile {
    const index = tileIndex(position);
    return self.tiles[index];
}

pub fn setTile(self: *Self, position: TileOffset, tile: Tile) void {
    const index = tileIndex(position);
    self.tiles[index] = tile;
}

fn tileIndex(position: TileOffset) usize {
    return @as(usize, @intCast(position.north))
        + @as(usize, @intCast(position.south_east)) * Layout.width
        + @as(usize, @intCast(position.height)) * Layout.area;
}