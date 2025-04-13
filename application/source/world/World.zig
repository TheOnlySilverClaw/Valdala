const std = @import("std");

const Allocator = std.mem.Allocator;
const Map = std.AutoHashMapUnmanaged;
const Chunk = @import("Chunk.zig");
const ChunkMap = Map(Chunk.Position, Chunk);
const Seed = u64;

const Self = @This();

allocator: Allocator,
seed: Seed,
chunks: ChunkMap,

pub fn init(allocator: Allocator, seed: Seed) Allocator.Error!Self {
	
	var chunks = ChunkMap.empty;
	try chunks.ensureTotalCapacity(allocator, 1024);
	
	return .{
		.allocator = allocator,
		.seed = seed,
		.chunks = chunks
	};
}

pub fn getChunk(self: Self, position: Chunk.Position) ?*Chunk {
	return self.chunks.getPtr(position);
}

pub fn requestChunk(self: Self, position: Chunk.Position) Allocator.Error!*Chunk {
	
	if(self.chunks.getPtr(position)) |chunk| {
		return chunk;
	} else {
		try self.loadChunk(position);
		return self.chunks.getPtr(position).?;
	}
}

fn loadChunk(self: Self, position: Chunk.Position) Allocator.Error!Chunk {

	std.log.debug("load chunk {d} {d} {d}", .{ position.x, position.y, position.z });

	const generated = Chunk {
		.blocks = .{ 1 ** (Chunk.width * Chunk.width * Chunk.height) }
	};
	try self.chunks.getOrPut(self.allocator, position, generated);

	return generated;
}

pub fn deinit(self: *Self) void {
	self.chunks.deinit(self.allocator);
}