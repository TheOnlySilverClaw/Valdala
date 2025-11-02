const std = @import("std");
const math = std.math;
const coordinate = @import("coordinate");
const algebra = @import("algebra");
const fastnoise = @import("fastnoise");
const log = std.log.scoped(.terrain);

const Allocator = std.mem.Allocator;
const Hash = std.hash.XxHash3;
const Terrain = @import("Terrain.zig");
const Chunk = @import("Chunk.zig");
const Tile = @import("Tile.zig");
const Vector2 = algebra.Vector2;
const Vector3 = algebra.Vector3;
const Grid = coordinate.hexagon.Grid;
const Noise = fastnoise.Noise(f32);

pub const Seed = i32;


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
noise_simplex_default: Noise,
noise_simplex_ridged: Noise,
noise_cellular: Noise,


pub fn init(allocator: Allocator, seed: Terrain.Seed, grid: Grid(i64, f32)) Self {
    
    const noise_seeds: [2]i32 = @bitCast(seed);

    // noise settings can be found here: https://auburn.github.io/FastNoiseLite/
    const noise_simplex_default = Noise {
        .seed = noise_seeds[0]
    };

    const noise_simplex_ridged = Noise {
        .seed = noise_seeds[1],
        .fractal_type = .ridged,
    };

    const noise_cellular = Noise {
        .seed = noise_seeds[0],
        .noise_type = .cellular
    };

    return .{
        .allocator = allocator,
        .seed = seed,
        .grid = grid,
        .noise_simplex_default = noise_simplex_default,
        .noise_simplex_ridged = noise_simplex_ridged,
        .noise_cellular = noise_cellular
    };
}

pub fn generateChunk(self: *Self, position: Chunk.Position) !Chunk {

    var chunk = try Chunk.init(self.allocator);
    const corner = Chunk.cornerToTilePosition(position);
    const hex_height = self.grid.hexagon.height;

    for(0..Chunk.layout.width) |south_east_offset| {
        for(0..Chunk.layout.width) |north_offset| {
            
            const tile_position = Chunk.Position {
                .north = corner.north + @as(i64, @intCast(north_offset)),
                .south_east = corner.south_east + @as(i64, @intCast(south_east_offset)),
                .height = corner.height + @as(i64, @intCast(0))
            };

            const center = self.grid.getCenter(tile_position);

            const height_scale = (
                self.noise_simplex_default.genNoise2D(center.x, center.y) * 2
                + self.noise_simplex_ridged.genNoise2D(center.x, center.y)
                + self.noise_cellular.genNoise2D(center.x, center.y)
                ) / 4;

            const altitude: i64 = @intFromFloat(@max((height_scale / hex_height * 40), Terrain.sea_level));
            
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
    
    if(parameters.altitude <= Terrain.sea_level) {
        return .water;
    }

    const tile: Tile = switch (parameters.depth) {
        1 => .topsoil,
        2...4 => .soil,
        else => .rock
    };
    return tile;
}

fn randomAt(self: Self, position: Vector2(f32)) f32 {
    
    const input: [8]u8 = @bitCast([2]f32 { position.x, position.y });
    const hashed: f32 = @floatFromInt(Hash.hash(self.seed, input));
    const maximum: f32 = @floatFromInt(math.maxInt(i64));
    return (hashed / maximum) - 1;
}
