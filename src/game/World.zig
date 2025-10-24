const std = @import("std");
const terrain_mod = @import("terrain");

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Player = @import("Player.zig");
const Terrain = terrain_mod.Terrain;

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
    self.terrain.deinit();
}