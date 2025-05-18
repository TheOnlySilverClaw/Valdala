const std = @import("std");
const log = std.log.scoped(.time);

const Self = @This();

/// A full ingame day and night cycle is 24 minutes
pub const day_length = std.time.ms_per_min * 24;

days_passed: u32,
day_offset: u64,

pub fn init() Self {
    return .{
        .days_passed = 0,
        .day_offset = 0
    };
}

pub fn update(self: *Self, delta: u64) !void {
    
    self.day_offset += delta;
    if(self.day_offset >= day_length) {
        self.day_offset -= day_length;
        self.days_passed += 1;
    }

}

pub fn dayProgress(self: Self) f32 {
    return @as(f32, @floatFromInt(self.day_offset)) / @as(f32, @floatFromInt(day_length));
}