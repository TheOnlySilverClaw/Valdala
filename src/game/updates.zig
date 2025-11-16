const std = @import("std");

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;

const Chunk = @import("terrain").Chunk;

pub const Game = struct {
    world: World,
};

pub const World = struct {
    load: List(Chunk.Position),
    unload: List(Chunk.Position)
};