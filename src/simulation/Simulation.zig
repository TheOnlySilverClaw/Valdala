const std = @import("std");

const Allocator = std.mem.Allocator;
const World = @import("world").World;
const Time = @import("Time.zig");

const Self = @This();

/// A time difference in milliseconds
pub const Delta = u64;

allocator: Allocator,
world: *World,
time: *Time,
running: bool,

pub fn init(allocator: Allocator) !Self {
    
    const world = try allocator.create(World);
    world.* = try World.init(allocator, 1234, undefined);
    const time = try allocator.create(Time);
    time.* = Time.init();

    return .{
        .allocator = allocator,
        .world = world,
        .time = time,
        .running = false
    };
}

pub fn deinit(self: Self) void {
    
    self.world.deinit();
    self.allocator.destroy(self.world);
    self.allocator.destroy(self.time);
}

pub fn start(self: *Self) !void {

    self.running = true;
    var last_update = std.time.milliTimestamp();

    while(self.running) {
        const update_start = std.time.milliTimestamp();
        const delta: Delta = @intCast(update_start - last_update);
        try self.update(delta);
        last_update = update_start;
    }
}

pub fn update(self: *Self, delta: Delta) !void {
    
    try self.time.update(delta);
    // just to keep the CPU from burning until we actually do things
    std.time.sleep(std.time.ns_per_s);
}

pub fn stop(self: *Self) void {
    self.running = false;
}