const std = @import("std");
const math = std.math;
const coordinate = @import("coordinate");
const fastnoise = @import("fastnoise");
const log = std.log.scoped(.terrain);

const Allocator = std.mem.Allocator;
const Map = std.AutoArrayHashMapUnmanaged;
const Color = @import("color").RGB;
const Tile = @import("Tile.zig");
const Chunk = @import("Chunk.zig");
const Generator = @import("Generator.zig");
const Grid = coordinate.hexagon.Grid;
const Noise = fastnoise.Noise(f32);

pub const Seed = u64;

const Self = @This();

/// maximum height from sea level in meters
pub const altitude_max = math.maxInt(i14);
pub const sea_level = 0;


allocator: Allocator,
seed: Seed,
generator: Generator,
grid: Grid(i64, f32),
chunks: Map(Chunk.Position, Chunk),
sky_color: Color,

pub fn init(allocator: Allocator, seed: Seed) !Self {
    
    const hexagon = coordinate.hexagon.Hexagon(f32).new(0.5, 0.5);
    const grid = coordinate.hexagon.Grid(i64, f32).of(hexagon);
    const generator = Generator.init(allocator, seed, grid);

    return .{
        .allocator = allocator,
        .seed = seed,
        .generator = generator,
        .grid = grid,
        .chunks = .empty,
        .sky_color = Color.of(0.2, 0.2, 1.0)
    };
}

pub fn deinit(self: *Self) void {
    self.unloadChunks();
}

pub fn loadChunks(self: *Self, center: Chunk.Position, distance: u32) !void {

    const limit: usize = distance * 2 - 1;
    const half: i64 = distance / 2;

    for(0..limit) |south_east| {
        for(0..limit) |north| {
            for(0..limit) |height| {

                const position = Chunk.Position {
                    .north = @intCast(center.north + @as(i64, @intCast(north)) - half),
                    .south_east = @intCast(center.south_east + @as(i64, @intCast(south_east)) - half),
                    .height = @intCast(center.height + @as(i64, @intCast(height)) - half)
                };
                
                _ = try self.loadChunk(position);
            }
        }
    }
}

pub fn getChunk(self: Self, position: Chunk.Position) ?Chunk {
    return self.chunks.get(position);
}

pub fn loadChunk(self: *Self, position: Chunk.Position) !Chunk {

    if(self.chunks.get(position)) |chunk| {
        return chunk;
    }

    return try self.generateChunk(position);
}

pub fn generateChunk(self: *Self, position: Chunk.Position) !Chunk {

    var timer = try std.time.Timer.start();
    const chunk = try self.generator.generateChunk(position);
    try self.chunks.put(self.allocator, position, chunk);
    log.debug("generated chunk at {f} in {} ms", .{ position, timer.read() / std.time.ns_per_ms });
    
    return chunk;
}

pub fn unloadChunk(self: *Self, position: Chunk.Position) void {

    if(self.chunks.fetchSwapRemove(position)) |entry| {
        entry.value.deinit(self.allocator);
    }
}

pub fn unloadChunks(self: *Self) void {

    for(self.chunks.values()) |chunk| {
        chunk.deinit(self.allocator);
    }

    self.chunks.clearAndFree(self.allocator);
}

pub fn getTile(self: Self, position: Tile.Position) ?Tile {
    
    const chunk_position = Chunk.tileToChunkPosition(position);
    if(self.chunks.get(chunk_position)) |chunk| {
        const offset = Chunk.TileOffset {
            .north = @intCast(@mod(position.north, Chunk.layout.width)),
            .south_east = @intCast(@mod(position.south_east, Chunk.layout.width)),
            .height = @intCast(@mod(position.height, Chunk.layout.height))
        };
        return chunk.getTile(offset);
    }

    return null;
}



const testing = std.testing;

test getTile {

    const grid = Grid(i32, f32).of(coordinate.Hexagon(f32).new(0.25, 0.25));
    const world = try Self.init(testing.allocator, 1234, grid);
    try testing.expectEqual(Tile.air, world.getTile(Tile.Position.of(0, 0, 0)));
}