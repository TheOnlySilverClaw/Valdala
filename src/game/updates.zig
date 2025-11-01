const std = @import("std");

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;

const Chunk = @import("terrain").Chunk;

pub const Game = struct {
    allocator: Allocator,
    world: World,

    pub fn deinit(self: *Game) void {
        self.world.load.clearAndFree(self.allocator);
        self.world.unload.clearAndFree(self.allocator);
    }
};

pub const World = struct {
    load: List(Chunk.Position),
    unload: List(Chunk.Position)
};