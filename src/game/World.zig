const std = @import("std");
const log = std.log.scoped(.world);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Map = std.AutoArrayHashMapUnmanaged;
const Terrain = @import("terrain").Terrain;
const Chunk = @import("terrain").Chunk;
const Player = @import("Player.zig");

const Self = @This();


allocator: Allocator,
players: List(*Player),
terrain: Terrain,

pub fn init(allocator: Allocator, seed: Terrain.Seed) !Self {
    
    const terrain = try Terrain.init(allocator, seed);

    return .{
        .allocator = allocator,
        .players = .empty,
        .terrain = terrain
    };
}

pub fn deinit(self: *Self) void {

    for(self.players.items) |player| {
        self.allocator.destroy(player);
    }
    self.players.clearAndFree(self.allocator);
    self.terrain.deinit();
}

pub fn createPlayer(self: *Self, player: Player) !*Player {
    
    const ptr = try self.allocator.create(Player);
    ptr.* = player;
    try self.players.append(self.allocator, ptr);
    return ptr;
}

pub fn updateTerrain(self: *Self) !void {

    var terrain = &self.terrain;
    const grid = terrain.grid;

    for(self.players.items) |player| {
        const tile_position = grid.getHexagon(player.transform.position);
        const chunk_position = Chunk.tileToChunkPosition(tile_position);
        try terrain.loadChunks(chunk_position, 2);
    }

    // var load_positions = Map(Chunk.Position, void).empty;
    // defer load_positions.clearAndFree(self.allocator);
    // for(self.players.items) |player| {
    //     const chunk_position = Chunk.tileToChunkPosition(tile_position);
    //     if(!terrain.chunks.contains(chunk_position)) {
    //         try load_positions.put(self.allocator, chunk_position, {});
    //     }
    // }

    // log.debug("chunk positions to load: {any}", .{ load_positions.keys() });
    // for(load_positions.keys()) |position| {
    //     _ = try terrain.loadChunk(position);
    // }
}