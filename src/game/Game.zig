const std = @import("std");
const color = @import("color");

const Allocator = std.mem.Allocator;
const World = @import("World.zig");
const Time = @import("Time.zig");
const Update = @import("updates.zig").Game;

const Self = @This();


allocator: Allocator,
world: *World,
time: Time,

pub fn init(allocator: Allocator) !Self {
    
    const world = try allocator.create(World);
    world.* = try World.init(allocator, 1234);
    const time = Time.init();

    return .{
        .allocator = allocator,
        .world = world,
        .time = time
    };
}

pub fn deinit(self: Self) void {
    
    self.world.deinit();
    self.allocator.destroy(self.world);
}

pub fn update(self: *Self, update_arena: Allocator, delta: u64) !Update {
    
    try self.time.update(delta);
    const world_updates = try self.world.updateTerrain(update_arena);
    
    return .{
        .world = world_updates
    };
}
