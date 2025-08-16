const std = @import("std");
const math = std.math;
const color = @import("color");
const world = @import("world");
const algebra = @import("algebra");
const log = std.log.scoped(.scene);

const Allocator = std.mem.Allocator;
const Camera = @import("Camera.zig");
const Chunk = @import("Chunk.zig");
const Tile = @import("Tile.zig");
const Vector = algebra.Vector3(f32);

const Self = @This();


allocator: Allocator,
camera: Camera,
chunks: []Chunk,
chunk_distance: u32,
sky_color: color.RGB,

pub fn init(allocator: Allocator, chunk_distance: u32, aspect: f32) !Self {

    const chunk_volume = try math.powi(u32, chunk_distance, 3);
    const chunks = try allocator.alloc(Chunk, chunk_volume);

    var random = std.Random.DefaultPrng.init(123);

    for(0..chunk_distance) |x| {
        for(0..chunk_distance) |y| {
            for(0..chunk_distance) |z| {
                const index = z + y * chunk_distance + x * chunk_distance * chunk_distance;
                const start_x: f32 = @floatFromInt(x * Chunk.Layout.width);
                const start_y: f32 = @floatFromInt(y * Chunk.Layout.width);
                const start_z: f32 = @floatFromInt(z * Chunk.Layout.height);
                log.debug("chunk index {} gets position {d} {d} {d}", .{ index, start_x, start_y, start_z});
                const start = Vector.of(start_x, start_y, start_z);
                chunks[index] = Chunk.init(start);
            }
        }
    }

    for(chunks) |*chunk| {
        for(0..Chunk.Layout.width) |x| {
            for(0..Chunk.Layout.width) |y| {
                for(0..4) |z| {
                    const position = Chunk.TileOffset {
                        .north = @intCast(x),
                        .south_east = @intCast(y),
                        .height = @intCast(z)
                    };
                    const tile_type = @as(u16, @truncate(random.next())) % 4;
                    const tile = Tile {
                        .index = tile_type,
                        .orientation = .full
                    };
                    chunk.setTile(position, tile);
                }
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