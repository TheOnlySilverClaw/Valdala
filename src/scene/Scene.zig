const std = @import("std");
const math = std.math;
const color = @import("color");
const algebra = @import("algebra");
const log = std.log.scoped(.scene);

const Allocator = std.mem.Allocator;
const Map = std.AutoHashMapUnmanaged;
const List = std.ArrayListUnmanaged;
const Camera = @import("Camera.zig");
const ChunkMesh = @import("ChunkMesh.zig");
const ChunkMesher = @import("ChunkMesher.zig");
const Tile = @import("Tile.zig");
const Vector = algebra.Vector3;
const Terrain = @import("terrain").Terrain;
const Chunk = @import("terrain").Chunk;
const SpscQueue = @import("queue.zig").SpscQueue;

const queue_capacity = std.math.log2(16);
const InQueue = SpscQueue(struct { position: Chunk.Position, chunk: Chunk }, queue_capacity);
const OutQueue = SpscQueue(struct { position: Chunk.Position, mesh: ChunkMesh }, queue_capacity);

const Self = @This();


allocator: Allocator,
camera: Camera,
chunks: Map(Chunk.Position, ChunkMesh),
chunk_in_queue: InQueue,
chunk_out_queue: OutQueue,
chunk_distance: u32,
sky_color: color.RGB,

pub fn init(allocator: Allocator, chunk_distance: u32, aspect: f32) !Self {

    const chunks = Map(Chunk.Position, ChunkMesh).empty;

    var camera = Camera.init(math.degreesToRadians(70), aspect, 0.001, 1000);
    // move up
    camera.transform.moveZ(20.0);

    return .{
        .allocator = allocator,
        .chunk_distance = chunk_distance,
        .chunks = chunks,
        .chunk_in_queue = .{},
        .chunk_out_queue = .{},
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

pub fn addChunkMesh(self: *Self, position: Chunk.Position, mesh: ChunkMesh) Allocator.Error!void {
    try self.chunks.put(self.allocator, position, mesh);
}

pub fn updateTerrain(self: *Self, terrain: Terrain, load_positions: List(Chunk.Position), unload_positions: List(Chunk.Position)) !void {

    for(load_positions.items) |position| {
        // TODO check distance either here or during world update
        if(!self.chunks.contains(position)) {
            if(terrain.chunks.get(position)) |chunk| {
                if(chunk.visible) {
                    if (self.chunk_in_queue.enqueue(.{ .position = position, .chunk = chunk })) {
                        log.debug("enqueued chunk at {f}", .{position});
                    } else {
                        log.warn("could not enqueue chunk at {f}", .{position});
                    }
                }
            }
        }
    }
    
    while (self.chunk_out_queue.dequeue()) |chunk| {
        try self.chunks.put(self.allocator, chunk.position, chunk.mesh);
    }

    for(unload_positions.items) |position| {
        if(self.chunks.fetchRemove(position)) |entry| {
            const mesh = entry.value;
            mesh.destroy();
        }
    }
}

pub fn launchChunkMesher(mesher: *ChunkMesher, in_queue: *InQueue, out_queue: *OutQueue) void {

    while (true) {
        if (in_queue.dequeue()) |chunk| {
            const mesh = mesher.generate(chunk.position, chunk.chunk) catch |e| {
                log.err("could not mesh chunk at {f}: {t}", .{chunk.position, e});
                continue;
            };

            while (!out_queue.enqueue(.{ .position = chunk.position, .mesh = mesh })) {
                std.atomic.spinLoopHint();
            }

            log.debug("enqueued chunk mesh at {f}", .{chunk.position});
        } else {
            std.atomic.spinLoopHint();
        }
    }
}