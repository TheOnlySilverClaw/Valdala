const std = @import("std");
const color = @import("color");

const Allocator = std.mem.Allocator;
const World = @import("world").World;
const Time = @import("Time.zig");

const Self = @This();


allocator: Allocator,
world: *World,
time: *Time,
last_update: i64,

pub fn init(allocator: Allocator) !Self {
    
    const world = try allocator.create(World);
    world.* = try World.init(allocator, 1234);
    const time = try allocator.create(Time);
    time.* = Time.init();

    return .{
        .allocator = allocator,
        .world = world,
        .time = time,
        .last_update = undefined
    };
}

pub fn deinit(self: Self) void {
    
    self.world.deinit();
    self.allocator.destroy(self.world);
    self.allocator.destroy(self.time);
}

pub fn start(self: *Self) void {
    self.last_update = std.time.milliTimestamp();
}

pub fn tick(self: *Self) !void {
    
    const update_start = std.time.milliTimestamp();
    const delta: u64 = @intCast(update_start - self.last_update);
    try self.update(delta);
    self.last_update = update_start;
}

pub fn update(self: *Self, delta: u64) !void {
    
    try self.time.update(delta);
    // just to keep the CPU from burning until we actually do things

    self.world.sky_color = color.RGB.of(0.2, 0.2, 0.9 - self.time.dayProgress());

    std.time.sleep(std.time.ns_per_s);
}
