const std = @import("std");
const color = @import("color");

const Allocator = std.mem.Allocator;
const World = @import("world").World;
const Time = @import("Time.zig");

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

pub fn update(self: *Self, delta: u64) !void {
    
    try self.time.update(delta);
}
