const std = @import("std");
const math = std.math;
const color = @import("color");
const algebra = @import("algebra");
const log = std.log.scoped(.scene);

const Allocator = std.mem.Allocator;
const Atomic = std.atomic.Value;
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

const ChunkToMesh = struct { position: Chunk.Position, chunk: Chunk };

const queue_capacity = std.math.log2(32);
const InQueue = SpscQueue(ChunkToMesh, queue_capacity);
const OutQueue = SpscQueue(struct { position: Chunk.Position, mesh: ChunkMesh }, queue_capacity);

const Self = @This();


allocator: Allocator,
camera: Camera,
chunks: Map(Chunk.Position, ChunkMesh),
chunk_in_queue: InQueue,
chunk_out_queue: OutQueue,
chunks_to_queue: List(ChunkToMesh),
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
        .chunks_to_queue = .empty,
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

    for (self.chunks_to_queue.items) |chunkToMesh| chunkToMesh.chunk.deinit(self.allocator);
    self.chunks_to_queue.deinit(self.allocator);
}

pub fn addChunkMesh(self: *Self, position: Chunk.Position, mesh: ChunkMesh) Allocator.Error!void {
    try self.chunks.put(self.allocator, position, mesh);
}

pub fn updateTerrain(self: *Self, terrain: Terrain, load_positions: List(Chunk.Position), unload_positions: List(Chunk.Position)) !void {

    for(load_positions.items) |position| {
        // TODO check distance either here or during world update
        if(!self.chunks.contains(position)) {
            if(terrain.getChunk(position)) |chunk| {
                if(chunk.visible) {
                    const chunkDupe = try chunk.dupe(self.allocator);
                    errdefer chunkDupe.deinit(self.allocator);

                    const chunkToMesh = ChunkToMesh{ .position = position, .chunk = chunkDupe };

                    if (self.chunk_in_queue.enqueue(chunkToMesh)) {
                        log.debug("enqueued chunk at {f}", .{position});
                    } else {
                        try self.chunks_to_queue.append(self.allocator, chunkToMesh);
                    }
                }
            }
        }
    }

    while (self.chunks_to_queue.pop()) |chunkToMesh| {
        if (self.chunk_in_queue.enqueue(chunkToMesh)) {
            log.debug("enqueued chunk at {f}", .{chunkToMesh.position});
        } else {
            self.chunks_to_queue.appendAssumeCapacity(chunkToMesh);
            break;
        }
    }

    while (self.chunk_out_queue.dequeue()) |chunkToMesh| {
        if (terrain.getChunk(chunkToMesh.position)) |chunk| {
            if (chunk.visible) {
                try self.chunks.put(self.allocator, chunkToMesh.position, chunkToMesh.mesh);
            } else {
                chunkToMesh.mesh.destroy();
            }
        }
    }

    for(unload_positions.items) |position| {
        if(self.chunks.fetchRemove(position)) |entry| {
            const mesh = entry.value;
            mesh.destroy();
        }
    }
}

pub fn launchChunkMesher(allocator: Allocator, exit: *Atomic(bool), mesher: *ChunkMesher, in_queue: *InQueue, out_queue: *OutQueue) void {

    while (!exit.load(.acquire)) {
        if (in_queue.dequeue()) |chunkToMesh| {
            defer chunkToMesh.chunk.deinit(allocator);

            const mesh = mesher.generate(chunkToMesh.position, chunkToMesh.chunk) catch |e| {
                log.err("could not mesh chunk at {f}: {t}", .{chunkToMesh.position, e});
                continue;
            };

            while (!out_queue.enqueue(.{ .position = chunkToMesh.position, .mesh = mesh })) {
                std.atomic.spinLoopHint();
            }

            log.debug("enqueued chunk mesh at {f}", .{chunkToMesh.position});
        } else {
            std.atomic.spinLoopHint();
        }
    }
    
    while (in_queue.dequeue()) |chunkToMesh| {
        chunkToMesh.chunk.deinit(allocator);
    }
}