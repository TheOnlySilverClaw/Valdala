const std = @import("std");
const algebra = @import("algebra");
const coordinate = @import("coordinate");

const Allocator = std.mem.Allocator;
const Tile = @import("Tile.zig");


pub const TileOffset = struct {
    north: u6,
    south_east: u6,
    height: u4,

    pub fn of(north: u6, south_east: u6, height: u4) TileOffset {
        return .{
            .north = north,
            .south_east = south_east,
            .height = height
        };
    }
};

pub const Layout = struct {
    pub const width = 64;
    pub const height = 16;
};

pub const Layer = []Tile;

pub const Position = algebra.Vector3(i32);

const Self = @This();


layers: []Layer,

pub fn init(allocator: Allocator, height: u32) Self {
    
    const layers = try allocator.alloc(Layer, height);
    for(layers) |*layer| {
        layer = try allocator.alloc(Tile, Layout.width * Layout.width);
        @memset(layer, Tile.air);
    }

    return .{
        .layers = layers
    };
    
}

pub fn getTile(self: Self, offset: TileOffset) Tile {
    
    if(offset.height >= self.layers.len) {
        return Tile.air;
    }
    
    const layer_index = @as(u64, offset.south_east) * Layout.width + offset.north;
    return self.layers[offset.height][layer_index];
}