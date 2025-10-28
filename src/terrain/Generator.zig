const std = @import("std");
const math = std.math;
const coordinate = @import("coordinate");
const fastnoise = @import("fastnoise");
const log = std.log.scoped(.terrain);

const Allocator = std.mem.Allocator;
const Hash = std.hash.XxHash3;
const Terrain = @import("Terrain.zig");
const Chunk = @import("Chunk.zig");
const Tile = @import("Tile.zig");
const Grid = coordinate.hexagon.Grid;
const Noise = fastnoise.Noise(f32);

pub const Seed = i32;

const SurfacePosition = packed struct {
    north: i64,
    south_east: i64
};

const TileParameters = struct {
    /// height from sea level, in tile heights
    altitude: i64,
    /// distance from surface, in tile heights
    depth: i64
};

const Self = @This();

allocator: Allocator,
seed: Terrain.Seed,
grid: Grid(i64, f32),
noise: Noise,


pub fn init(allocator: Allocator, seed: Terrain.Seed, grid: Grid(i64, f32)) Self {
    
    const noise_seeds: [2]i32 = @bitCast(seed);

    const noise = Noise {
        .seed = noise_seeds[0]
    };

    return .{
        .allocator = allocator,
        .seed = seed,
        .grid = grid,
        .noise = noise
    };
}

pub fn generateChunk(self: *Self, position: Chunk.Position) !Chunk {

    var chunk = try Chunk.init(self.allocator);
    const corner = Chunk.cornerToTilePosition(position);
    const hex_height = self.grid.hexagon.height;

    for(0..Chunk.layout.width) |south_east_offset| {
        for(0..Chunk.layout.width) |north_offset| {
            
            const surface_position = SurfacePosition {
                .north = corner.north + @as(i64, @intCast(north_offset)),
                .south_east = corner.south_east + @as(i64, @intCast(south_east_offset))
            };

            const noise_height = self.noiseAt(surface_position, 1.0);
            const random_height = self.randomAt(surface_position);
            const roughness = self.noiseAt(surface_position, 20);

            const normal_height = math.pow(f32, noise_height, 3) + (random_height * roughness * 0.5);
            const altitude: i64 = @intFromFloat(normal_height / hex_height * 10);
            const tile_height = altitude - corner.height;

            if(tile_height >= 0) {
                chunk.visible = true;
                const height_limit = @min(tile_height, Chunk.layout.height);

                for(0..@intCast(height_limit)) |height_offset| {

                    const tile_depth = tile_height - @as(i64, @intCast(height_offset));

                    const offset = Chunk.TileOffset {
                        .south_east = @intCast(south_east_offset),
                        .north = @intCast(north_offset),
                        .height = @intCast(height_offset)
                    };

                    const parameters = TileParameters {
                        .altitude = altitude,
                        .depth = tile_depth
                    };
                    const tile = generateTile(parameters);
                    chunk.setTile(offset, tile);
                }
            }
        }
    }

    return chunk;
}

fn generateTile(parameters: TileParameters) Tile {
    
    if(parameters.altitude < Terrain.sea_level) {
        return .water;
    }

    const tile: Tile = switch (parameters.depth) {
        1 => .topsoil,
        2...4 => .soil,
        else => .rock
    };
    return tile;
}

fn randomAt(self: Self, position: SurfacePosition) f32 {
    
    const input: [16]u8 = @bitCast(position);
    const hashed: f32 = @floatFromInt(Hash.hash(self.seed, input));
    const maximum: f32 = @floatFromInt(math.maxInt(i64));
    return (hashed / maximum) - 1;
}

fn noiseAt(self: Self, position: SurfacePosition, scale: f32) f32 {
    const x: f32 = @floatFromInt(position.north);
    const y: f32 = @floatFromInt(position.south_east);
    return self.noise.genNoise2D(x / scale, y / scale);
}