const std = @import("std");
const math = std.math;
const color = @import("color");

const Allocator = std.mem.Allocator;
const Camera = @import("Camera.zig");
const ChunkMesh = @import("ChunkMesh.zig");

const Self = @This();


allocator: Allocator,
camera: Camera,
chunks: []*ChunkMesh,
chunk_distance: u32,
sky_color: color.RGB,

pub fn init(allocator: Allocator, chunk_distance: u32) !Self {

    const chunks = try allocator.alloc(*ChunkMesh, try math.powi(u32, chunk_distance, 2));

    return .{
        .allocator = allocator,
        .chunk_distance = chunk_distance,
        .chunks = chunks,
        .camera = Camera.new(),
        .sky_color = color.RGB.of(1.0, 0.0, 0.0)
    };
}

pub fn deinit(self: *Self) void {
    self.allocator.free(self.chunks);
}

pub fn render(self: Self, delta: u64) !void {
    _ = self;
    _ = delta;
}