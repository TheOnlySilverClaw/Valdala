const std = @import("std");
const math = std.math;

const Allocator = std.mem.Allocator;
const Camera = @import("Camera.zig");
const ChunkMesh = @import("ChunkMesh.zig");

const Self = @This();


allocator: Allocator,
camera: Camera,
chunks: []*ChunkMesh,
chunk_distance: u32,

pub fn init(allocator: Allocator, chunk_distance: u32) !Self {

    const chunks = try allocator.alloc(*ChunkMesh, math.powi(u32, chunk_distance, 2));

    return .{
        .allocator = allocator,
        .chunk_distance = chunk_distance,
        .chunks = chunks,
        .camera = Camera {}
    };
}

pub fn render(self: Self, delta: u64) !void {
    _ = self;
    _ = delta;
}