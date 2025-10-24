const std = @import("std");
const math = std.math;
const color = @import("color");
const algebra = @import("algebra");
const terrain = @import("terrain");
const log = std.log.scoped(.scene);

const Map = std.AutoHashMapUnmanaged;
const Allocator = std.mem.Allocator;
const Camera = @import("Camera.zig");
const ChunkMesh = @import("ChunkMesh.zig");
const Tile = @import("Tile.zig");
const Vector = algebra.Vector3;

const Self = @This();


allocator: Allocator,
camera: Camera,
chunks: Map(terrain.Chunk.Position, ChunkMesh),
chunk_distance: u32,
sky_color: color.RGB,

pub fn init(allocator: Allocator, chunk_distance: u32, aspect: f32) !Self {

    const chunks = Map(terrain.Chunk.Position, ChunkMesh).empty;

    var camera = Camera.init(math.degreesToRadians(70), aspect, 0.001, 1000);
    // move up
    camera.transform.moveZ(20.0);

    return .{
        .allocator = allocator,
        .chunk_distance = chunk_distance,
        .chunks = chunks,
        .camera = camera,
        .sky_color = color.RGB.of(0.2, 0.2, 0.8)
    };
}

pub fn deinit(self: *Self) void {
    
    var chunk_iterator = self.chunks.valueIterator();
    while(chunk_iterator.next()) |chunk| {
        chunk.destroy();
    }
    self.chunks.clearAndFree(self.allocator);
}

pub fn addChunkMesh(self: *Self, position: terrain.Chunk.Position, mesh: ChunkMesh) Allocator.Error!void {
    try self.chunks.put(self.allocator, position, mesh);
}