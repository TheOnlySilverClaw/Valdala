const std = @import("std");
const math = std.math;


const compact_max: f32 = 255.0;

pub const RGB = struct {
    red: f32,
    green: f32,
    blue: f32,

    
    pub const Compact = extern struct {
        red: u8,
        green: u8,
        blue: u8,

        pub fn normalize(self: RGB.Compact) RGB {
            return .{
                .red = (@as(f32, @floatFromInt(self.red))) / compact_max,
                .green = (@as(f32, @floatFromInt(self.green))) / compact_max,
                .blue = @as(f32, @floatFromInt(self.blue)) / compact_max
            };
        }
    };

    pub fn of(red: f32, green: f32, blue: f32) RGB {
        return .{
            .red = red,
            .green = green,
            .blue = blue
        };
    }

    pub fn compact(self: RGB) RGB.Compact {
        return .{
            .red = @intFromFloat(@round(self.red * compact_max)),
            .green = @intFromFloat(@round(self.green * compact_max)),
            .blue = @intFromFloat(@round(self.blue * compact_max))
        };
    }

    pub fn toRGBA(self: RGB, alpha: f32) RGBA {
        return .{
            .red = self.red,
            .green = self.green,
            .blue = self.blue,
            .alpha = alpha
        };
    }
};


pub const RGBA = struct {
    red: f32,
    green: f32,
    blue: f32,
    alpha: f32,

    pub const Compact = extern struct {
        red: u8,
        green: u8,
        blue: u8,
        alpha: u8,

        pub fn normalize(self: RGBA.Compact) RGBA {
            return .{
                .red = (@as(f32, @floatFromInt(self.red))) / compact_max,
                .green = (@as(f32, @floatFromInt(self.green))) / compact_max,
                .blue = @as(f32, @floatFromInt(self.blue)) / compact_max,
                .alpha = @as(f32, @floatFromInt(self.alpha)) / compact_max,
            };
        }
    };

    pub fn of(red: f32, green: f32, blue: f32, alpha: f32) RGBA {
        return .{
            .red = red,
            .green = green,
            .blue = blue,
            .alpha = alpha
        };
    }

    pub fn compact(self: RGBA) RGBA.Compact {
        return .{
            .red = @intFromFloat(@round(self.red * compact_max)),
            .green = @intFromFloat(@round(self.green * compact_max)),
            .blue = @intFromFloat(@round(self.blue * compact_max)),
            .alpha = @intFromFloat(@round(self.alpha * compact_max)),
        };
    }

    pub fn toRGB(self: RGBA) RGB {
        return .{
            .red = self.red,
            .green = self.green,
            .blue = self.blue
        };
    }
};

const testing = std.testing;
const expectEqual = testing.expectEqual;
const expectApproxEqRel = testing.expectApproxEqRel;

test {
    const color = RGBA.of(0.0, 0.5, 1.0, 1.0);
    
    const compcacted = color.compact();
    try expectEqual(0, compcacted.red);
    try expectEqual(128, compcacted.green);
    try expectEqual(255, compcacted.blue);
    try expectEqual(255, compcacted.alpha);

    const normalized = compcacted.normalize();
    try expectEqual(color.red, normalized.red);
    try expectApproxEqRel(color.green, normalized.green, 0.01);
    try expectEqual(color.blue, normalized.blue);
    try expectEqual(color.alpha, normalized.alpha);
}