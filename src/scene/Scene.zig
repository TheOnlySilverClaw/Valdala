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

pub fn init(allocator: Allocator, chunk_distance: u32) !Self {

    const chunk_volume = try math.powi(u32, chunk_distance, 3);
    const chunks = try allocator.alloc(Chunk, chunk_volume);

    for(chunks) |*chunk| {
        chunk.* = Chunk.init(.zero);
    }

    return .{
        .allocator = allocator,
        .chunk_distance = chunk_distance,
        .chunks = chunks,
        .camera = Camera.new(),
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