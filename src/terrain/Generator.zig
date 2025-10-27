const std = @import("std");
const math = std.math;
const coordinate = @import("coordinate");
const fastnoise = @import("fastnoise");
const log = std.log.scoped(.terrain);

const Allocator = std.mem.Allocator;
const Terrain = @import("Terrain.zig");
const Chunk = @import("Chunk.zig");
const Tile = @import("Tile.zig");
const Grid = coordinate.hexagon.Grid;
const Noise = fastnoise.Noise(f32);

pub const Seed = i32;

const Self = @This();

allocator: Allocator,
seed: Terrain.Seed,
noise: Noise,

pub fn init(allocator: Allocator, seed: Terrain.Seed) Self {
    
    const noise_seeds: [2]i32 = @bitCast(seed);

    const noise = Noise {
        .seed = noise_seeds[0]
    };

    return .{
        .allocator = allocator,
        .seed = seed,
        .noise = noise
    };
}

pub fn generateChunk(self: *Self, position: Chunk.Position) !Chunk {

    var chunk = try Chunk.init(self.allocator);
    
    const start_north: f32 = @floatFromInt(position.north * Chunk.layout.width);
    const start_south_east: f32 = @floatFromInt(position.south_east * Chunk.layout.width);
    const chunk_height_factor: f32 = @floatFromInt(Chunk.layout.height);

    for(0..Chunk.layout.width) |south_east| {
        for(0..Chunk.layout.width) |north| {
            
            const world_north = start_north + @as(f32, @floatFromInt(north));
            const world_south_east = start_south_east + @as(f32, @floatFromInt(south_east));
            const normal_height = self.noise.genNoise2D(world_north, world_south_east);
            const world_height: i64 = @intFromFloat(normal_height * chunk_height_factor);
            const tile_height = world_height - position.height * Chunk.layout.height;

            if(tile_height >= 0) {
                chunk.visible = true;
                const height_limit = @min(tile_height, Chunk.layout.height);

                for(0..@intCast(height_limit)) |height| {

                    const offset = Chunk.TileOffset {
                        .south_east = @intCast(south_east),
                        .north = @intCast(north),
                        .height = @intCast(height)
                    };
                    chunk.setTile(offset, .{ .index = 1 });
                }
            }
        }
    }

    return chunk;
}