const matrix = @import("matrix.zig");
const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const formatGeneric = @import("format.zig").formatGeneric;

pub fn Vector2(comptime T: type) type {
    return extern struct {
        x: T,
        y: T,
        const Self = @This();

        pub const zeros: Self = .{ .x = 0, .y = 0 };

        pub fn toVector3(self: Self, z: T) Vector4(T) {
            return .{ .x = self.x, .y = self.y, .z = z };
        }

        pub fn toVector4(self: Self, z: T, w: T) Vector4(T) {
            return .{ .x = self.x, .y = self.y, .z = z, .w = w };
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try formatGeneric(self, T, 2, 1, fmt, options, writer); // Swap row and column for columnvector
        }
    };
}

pub fn Vector3(comptime T: type) type {
    return extern struct {
        x: T,
        y: T,
        z: T,
        const Self = @This();

        pub const zeros: Self = .{ .x = 0, .y = 0, .z = 0 };

        pub fn lengthSquared(self: Self) T {
            return self.x * self.x + self.y * self.y + self.z * self.z;
        }

        pub fn length(self: Self) T {
            return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
        }

        pub fn isNormalized(self: Self) bool {
            return @abs(self.lengthSquared() - 1.0) <= 1e-4;
        }

        pub fn of(x: T, y: T, z: T) Self {
            return .{ .x = x, .y = y, .z = z };
        }

        pub fn all(value: T) Self {
            return .{ .x = value, .y = value, .z = value };
        }

        pub fn toVector4(self: Self, w: T) Vector4(T) {
            return .{ .x = self.x, .y = self.y, .z = self.z, .w = w };
        }

        pub fn flip(self: Self) Vector3(T) {
            return .{ .x = -self.x, .y = -self.y, .z = -self.z };
        }

        pub fn add(self: Self, other: Self) Self {
            return .{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
        }

        pub fn sub(self: Self, other: Self) Self {
            return .{ .x = self.x - other.x, .y = self.y - other.y, .z = self.z - other.z };
        }

        pub fn elementwiseMultiply(self: Self, other: Self) Self {
            return .{ .x = self.x * other.x, .y = self.y * other.y, .z = self.z * other.z };
        }

        pub fn scalarMultiply(self: Self, other: T) Self {
            return .{ .x = self.x * other, .y = self.y * other, .z = self.z * other };
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        pub fn cross(self: Self, other: Self) Self {
            return .{
                .x = self.y * other.z - other.y * self.z,
                .y = self.z * other.x - other.z * self.x,
                .z = self.x * other.y - other.x * self.y,
            };
        }

        pub fn div(self: Self, other: T) Self {
            return .{ .x = self.x / other, .y = self.y / other, .z = self.z / other };
        }

        pub fn scaleUniform(self: Self, value: T) Self {
            return .{ .x = self.x * value, .y = self.y * value, .z = self.z * value };
        }

        pub fn normalized(self: Self) Self {
            const reciprocal = 1.0 / self.norm();
            assert(reciprocal > 0.0);
            return .{ .x = self.x * reciprocal, .y = self.y * reciprocal, .z = self.z * reciprocal };
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try formatGeneric(self, T, 3, 1, fmt, options, writer);
        }
    };
}

pub fn Vector4(comptime T: type) type {
    return extern struct {
        x: T,
        y: T,
        z: T,
        w: T,
        const Self = @This();

        pub const zeros: Self = .{ .x = 0, .y = 0, .z = 0, .w = 0 };

        pub fn addPoint(self: Self, other: Self) Self {
            return .{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z, .w = 1 };
        }

        pub fn addDirection(self: Self, other: Self) Self {
            return .{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z, .w = 0 };
        }

        pub fn of(x: T, y: T, z: T, w: T) Self {
            return .{ .x = x, .y = y, .z = z, .w = w };
        }

        pub fn toVector3(self: Self) Vector3(T) {
            return .{ .x = self.x, .y = self.y, .z = self.z };
        }

        pub fn flip(self: Self) Vector4(T) {
            return .{ .x = -self.x, .y = -self.y, .z = -self.z, .w = -self.w };
        }

        pub fn nomalized(self: Self) Self {
            return self.toVector3().normalized().to_vec4(self.w);
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
        }

        pub fn packU8(self: Self) u32 {
            if (@TypeOf(T) != f32) @compileError("type must be f32 to use this function");
            const r8g8b8a8 = packed struct { x: u8, y: u8, z: u8, w: u8 };
            const u32union = packed union { parts: r8g8b8a8, int: u32 };
            const packedU8 = u32union{ .parts = r8g8b8a8{
                .x = @intFromFloat(@round(std.math.clamp(self.x, 0, 1) * 255.0)),
                .y = @intFromFloat(@round(std.math.clamp(self.y, 0, 1) * 255.0)),
                .z = @intFromFloat(@round(std.math.clamp(self.z, 0, 1) * 255.0)),
                .w = @intFromFloat(@round(std.math.clamp(self.w, 0, 1) * 255.0)),
            } };
            return packedU8.int;
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try formatGeneric(self, T, 4, 1, fmt, options, writer);
        }
    };
}
