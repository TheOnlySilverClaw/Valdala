const std = @import("std");
const math = std.math;
const coordinate = @import("coordinate");
const fastnoise = @import("fastnoise");

const Map = std.AutoArrayHashMapUnmanaged;
const Allocator = std.mem.Allocator;
const Color = @import("color").RGB;
const Tile = @import("Tile.zig");
const Chunk = @import("Chunk.zig");
const Grid = coordinate.hexagon.Grid;
const Seed = i32;
const Noise = fastnoise.Noise(f32);

const Self = @This();


allocator: Allocator,
seed: Seed,
noise: Noise,
grid: Grid(i64, f32),
chunks: Map(Chunk.Position, Chunk),
sky_color: Color,

pub fn init(allocator: Allocator, seed: Seed) !Self {
    
    const hexagon = coordinate.hexagon.Hexagon(f32).new(0.5, 0.5);
    const grid = coordinate.hexagon.Grid(i64, f32).of(hexagon);
    const noise = Noise {
        .seed = seed
    };

    return .{
        .allocator = allocator,
        .seed = seed,
        .grid = grid,
        .noise = noise,
        .chunks = .empty,
        .sky_color = Color.of(0.2, 0.2, 1.0)
    };
}

pub fn deinit(self: *Self) void {
    
    for(self.chunks.values()) |chunk| {
        chunk.deinit(self.allocator);
    }

    self.chunks.clearAndFree(self.allocator);
}

pub fn loadChunk(self: *Self, position: Chunk.Position) !Chunk {

    if(self.chunks.get(position)) |chunk| {
        return chunk;
    }

    return try self.generateChunk(position);
}

pub fn generateChunk(self: *Self, position: Chunk.Position) !Chunk {

    var chunk = try Chunk.init(self.allocator);
    
    const start_north: f32 = @floatFromInt(position.north * Chunk.layout.width);
    const start_south_east: f32 = @floatFromInt(position.south_east * Chunk.layout.width);
    const chunk_height_factor: f32 = @floatFromInt(Chunk.layout.height / 2);

    for(0..Chunk.layout.width) |south_east| {
        for(0..Chunk.layout.width) |north| {
            
            const world_north = start_north + @as(f32, @floatFromInt(north));
            const world_south_east = start_south_east + @as(f32, @floatFromInt(south_east));
            const normal_height = self.noise.genNoise2D(world_north, world_south_east);
            const height: u16 = @intFromFloat((normal_height + 1.0) * chunk_height_factor);

            const offset = Chunk.TileOffset {
                .south_east = @intCast(south_east),
                .north = @intCast(north),
                .height = height
            };
            chunk.setTile(offset, .{ .index = 1 });
        }
    }

    try self.chunks.put(self.allocator, position, chunk);
    
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