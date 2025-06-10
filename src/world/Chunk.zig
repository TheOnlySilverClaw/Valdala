const std = @import("std");
const algebra = @import("algebra");
const coordinate = @import("coordinate");

const Allocator = std.mem.Allocator;
const Tile = @import("Tile.zig");

const TileOffset = coordinate.Position(u6, u4);

pub const layout = struct {
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
        layer = try allocator.alloc(Tile, layout.width * layout.width);
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
    
    const layer_index = @as(u64, offset.south_east) * layout.width + offset.north;
    return self.layers[offset.height][layer_index];
}