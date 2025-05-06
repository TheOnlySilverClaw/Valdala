const std = @import("std");
const log = std.log.scoped(.time);
const Delta = @import("Simulation.zig").Delta;

const Self = @This();

/// A full ingame day and night cycle is 24 minutes
pub const day_length = std.time.ms_per_min * 24;

days_passed: u32,
day_progress: Delta,

pub fn init() Self {
    return .{
        .days_passed = 0,
        .day_progress = 0
    };
}

pub fn update(self: *Self, delta: Delta) !void {
    
    log.info("day length {d}", .{ day_length });
    log.debug("delta {d}", .{ delta });
    self.day_progress += delta;
    if(self.day_progress >= day_length) {
        self.day_progress -= day_length;
        self.days_passed += 1;
    }

    const fraction: f32 = @as(f32, @floatFromInt(self.day_progress)) / @as(f32, @floatFromInt(day_length));
    log.debug("day progress: {d:.2}%", .{ fraction * 100.0 });
}