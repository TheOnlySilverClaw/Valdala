const std = @import("std");
const log = std.log.scoped(.world);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Map = std.AutoHashMapUnmanaged;
const Terrain = @import("terrain").Terrain;
const Chunk = @import("terrain").Chunk;
const Player = @import("Player.zig");
const Update = @import("updates.zig").World;

const Self = @This();


allocator: Allocator,
players: List(*Player),
chunk_distance: u32,
terrain: Terrain,

pub fn init(allocator: Allocator, seed: Terrain.Seed) !Self {
    
    const terrain = try Terrain.init(allocator, seed);

    return .{
        .allocator = allocator,
        .players = .empty,
        .chunk_distance = 3,
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

pub fn updateTerrain(self: *Self, update_arena: Allocator) !Update {
    
    var terrain = &self.terrain;
    const grid = terrain.grid;

    var visible_positions = Map(Chunk.Position, void).empty;
    try visible_positions.ensureTotalCapacity(update_arena, @intCast(terrain.chunks.count()));

    const distance = self.chunk_distance;
    const limit: usize = distance * 2 - 1;
    const half: i64 = distance / 2;

    for(self.players.items) |player| {
        
        const tile = grid.getHexagon(player.transform.position);
        const center = Chunk.tileToChunkPosition(tile);

        for(0..limit) |south_east| {
            for(0..limit) |north| {
                for(0..limit) |height| {
                
                    const position = Chunk.Position {
                        .north = @intCast(center.north + @as(i64, @intCast(north)) - half),
                        .south_east = @intCast(center.south_east + @as(i64, @intCast(south_east)) - half),
                        .height = @intCast(center.height + @as(i64, @intCast(height)) - half)
                    };

                    try visible_positions.put(update_arena, position, {});
                }
            }
        }
    }

    const loaded_positions = try update_arena.alloc(Chunk.Position, terrain.chunks.count());
    // copy, because unloading chunks could invalidate the position keys
    std.mem.copyForwards(Chunk.Position, loaded_positions, terrain.chunks.keys());

    var load_positions = List(Chunk.Position).empty;
    var unload_positions = List(Chunk.Position).empty;

    for(loaded_positions) |position| {
        if(!visible_positions.remove(position)) {
            terrain.unloadChunk(position);
            try unload_positions.append(update_arena, position);
        }
    }

    var unload_iterator = visible_positions.keyIterator();
    while(unload_iterator.next()) |position| {
        _ = try terrain.loadChunk(position.*);
        try load_positions.append(update_arena, position.*);
    }

    return .{
        .load = load_positions,
        .unload = unload_positions
    };
}