const std = @import("std");
const math = std.math;
const color = @import("color");
const world = @import("world");
const algebra = @import("algebra");
const fastnoise = @import("fastnoise");
const log = std.log.scoped(.scene);

const Allocator = std.mem.Allocator;
const Camera = @import("Camera.zig");
const Chunk = @import("Chunk.zig");
const Tile = @import("Tile.zig");
const Vector = algebra.Vector3(f32);
const Noise = fastnoise.Noise(f32);

const Self = @This();


allocator: Allocator,
camera: Camera,
chunks: []Chunk,
chunk_distance: u32,
sky_color: color.RGB,

pub fn init(allocator: Allocator, chunk_distance: u32, aspect: f32) !Self {

    const chunk_volume = try math.powi(u32, chunk_distance, 3);
    const chunks = try allocator.alloc(Chunk, chunk_volume);

    // TODO all this should be done when chunk updates arrive

    const noise = Noise {};

    for(0..chunk_distance) |x| {
        for(0..chunk_distance) |y| {
            for(0..chunk_distance) |z| {
                const index = z + y * chunk_distance + x * chunk_distance * chunk_distance;
                const positiion = Chunk.Position.of
                    (@intCast(x * Chunk.Layout.width), @intCast(y * Chunk.Layout.width), @intCast(z * Chunk.Layout.height));
                chunks[index] = Chunk.init(positiion);
            }
        }
    }

    for(chunks) |*chunk| {
        if(chunk.position.height != 0) continue;
        for(0..Chunk.Layout.width) |x| {
            for(0..Chunk.Layout.width) |y| {

                const height = noise.genNoise2D(@floatFromInt(x), @floatFromInt(y));
                const z: u4 = @intFromFloat((height + 1.0) * 8.0);
                const position = Chunk.TileOffset {
                    .north = @intCast(x),
                    .south_east = @intCast(y),
                    .height = z
                };
                const tile_type = 1;
                const tile = Tile {
                    .index = tile_type,
                    .orientation = .full
                };
                chunk.setTile(position, tile);
            }
        }
    }

    var camera = Camera.init(math.degreesToRadians(70), aspect);
    // move up
    camera.moveZ(20.0);
    // look down
    // camera.rotatePitch(math.degreesToRadians(90));

    return .{
        .allocator = allocator,
        .chunk_distance = chunk_distance,
        .chunks = chunks,
        .camera = camera,
        .sky_color = color.RGB.of(0.2, 0.2, 0.8)
    };
}

pub fn deinit(self: *Self) void {
    
    for(self.chunks) |chunk| {
        chunk.deinit(self.allocator);
    }
    self.allocator.free(self.chunks);
}

pub fn render(self: Self, delta: u64) !void {
    _ = self;
    _ = delta;
}