const std = @import("std");
const math = std.math;
const coordinate = @import("coordinate");

const Allocator = std.mem.Allocator;
const Tile = @import("Tile.zig");
const Chunk = @import("Chunk.zig");
const ChunkMap = std.AutoHashMapUnmanaged(Chunk.Position, *Chunk);
const Grid = coordinate.Grid;
const Seed = u64;

const Self = @This();


allocator: Allocator,
seed: Seed,
grid: Grid(i32, f32),
chunks: ChunkMap,

pub fn init(allocator: Allocator, seed: Seed, grid: Grid(i32, f32)) !Self {
    
    return .{
        .allocator = allocator,
        .seed = seed,
        .grid = grid,
        .chunks = ChunkMap.empty
    };
}

pub fn loadChunk(self: Self, position: Chunk.Position) !*Chunk {

    if(self.chunks.get(position)) |chunk| {
        return chunk;
    }

    try self.generateChunk(position);
}

pub fn generateChunk(self: Self, position: Chunk.Position) !*Chunk {

    _ = self;
    _ = position;

    const chunk: Chunk = undefined;
    @memset(chunk.tiles, Tile.air);

    return chunk;
}

pub fn getTile(self: Self, position: Tile.Position) Tile {
    
    const offset = Chunk.TileOffset {
        .north = @intCast(@mod(position.north, Chunk.Layout.width)),
        .south_east = @intCast(@mod(position.south_east, Chunk.Layout.width)),
        .height = @intCast(@mod(position.height, Chunk.Layout.height))
    };

    const center = self.grid.getCenter(position);

    const chunk_position = Chunk.Position {
        .x = @intFromFloat(center.x / @as(f32, @floatFromInt(Chunk.Layout.width))),
        .y = @intFromFloat(center.y / @as(f32, @floatFromInt(Chunk.Layout.width))),
        .z = @intFromFloat(center.z / @as(f32, @floatFromInt(Chunk.Layout.height))),
    };

    const chunk = self.chunks.get(chunk_position);
    if(chunk) |c| {
        return c.getTile(offset);
    }

    return Tile.air;
}



const testing = std.testing;

test getTile {

    const grid = Grid(i32, f32).of(coordinate.Hexagon(f32).new(0.25, 0.25));
    const world = try Self.init(testing.allocator, 1234, grid);
    try testing.expectEqual(Tile.air, world.getTile(Tile.Position.of(0, 0, 0)));
}