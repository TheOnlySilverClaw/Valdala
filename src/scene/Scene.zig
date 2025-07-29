const std = @import("std");
const math = std.math;
const color = @import("color");
const world = @import("world");

const Allocator = std.mem.Allocator;
const Camera = @import("Camera.zig");
const Chunk = @import("Chunk.zig");
const Tile = @import("Tile.zig");

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

    for(chunks) |*chunk| {
        chunk.* = Chunk.init(.zero);
        for(0..Chunk.Layout.width) |x| {
            for(0..Chunk.Layout.width) |y| {
                const position = Chunk.TileOffset {
                    .north = @intCast(x),
                    .south_east = @intCast(y),
                    .height = 0
                };
                const tile_type = @as(u16, @truncate(random.next())) % 2;
                const tile = Tile {
                    .index = tile_type,
                    .orientation = .full
                };
                chunk.setTile(position, tile);
            }
        }
    }

    return .{
        .allocator = allocator,
        .chunk_distance = chunk_distance,
        .chunks = chunks,
        .camera = Camera.new(math.degreesToRadians(120), aspect),
        .sky_color = color.RGB.of(0.0, 0.0, 0.0)
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