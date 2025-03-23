//! TODO: run benchmarks on inlining
//!
//!
//!
const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const formatGeneric = @import("module.zig").formatGeneric;

pub fn Quaternion(comptime T: type) type {
    if (@typeInfo(T) != .float) @compileError("Quaternion must be of type float");
    const Vector3 = @import("vector.zig").Vector3(T);
    const Matrix4x4 = @import("matrix.zig").Matrix4x4(T);

    return struct {
        w: T,
        x: T,
        y: T,
        z: T,

        const Self = @This();
        pub const identity: Self = .{ .w = 1, .x = 0, .y = 0, .z = 0 };
        // TODO: add useful defaults
        // pub const ...
        // pub const ...

        pub fn aroundAxis(axis: Vector3, angle: T) Self {
            assert(axis.isNormalized());
            const half_angle = angle / 2.0;
            const sin = @sin(half_angle);
            const cos = @cos(half_angle);
            return .{
                .x = axis.x * sin,
                .y = axis.y * sin,
                .z = axis.z * sin,
                .w = cos,
            };
        }

        pub fn add(self: *const Self, other: *const Self) Self {
            return .{
                .x = self.x + other.x,
                .y = self.x + other.y,
                .z = self.x + other.z,
                .w = self.x + other.w,
            };
        }

        pub fn multiply(self: *const Self, other: *const Self) Self {
            assert(self.isNormalized());
            assert(other.isNormalized());

            const result: Self = .{
                .x = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y,
                .y = self.w * other.y + self.y * other.w + self.z * other.x - self.x * other.z,
                .z = self.w * other.z + self.z * other.w + self.x * other.y - self.y * other.x,
                .w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z,
            };
            return result;
        }

        pub fn rotateVector3(self: *const Self, v: *const Vector3) Vector3 {
            const w = self.w;
            const r: Vector3 = .{ .x = self.x, .y = self.y, .z = self.z };
            const t = r.cross(v).scalarMultiply(2.0);
            return v.add(t.scalarMultiply(w)).add(r.cross(&t));
        }

        pub fn inverse(self: Self) Self {
            assert(self.isNormalized());
            return self.conjugate();
        }

        pub fn conjugate(self: Self) Self {
            return .{ .x = -self.x, .y = -self.y, .z = -self.z, .w = self.w };
        }

        pub fn dot(self: Self, other: Self) T {
            return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;
        }

        pub fn normalized(self: Self) Self {
            const reciprocal = 1.0 / self.length();
            assert(reciprocal > 0.0);
            return .{ .x = self.x * reciprocal, .y = self.y * reciprocal, .z = self.z * reciprocal, .w = self.w * reciprocal };
        }

        pub fn isNormalized(self: Self) bool {
            return @abs(self.lengthSquared() - 1.0) <= 1e-4;
        }

        pub fn lengthSquared(self: Self) T {
            return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w;
        }

        pub fn length(self: Self) T {
            return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w);
        }

        pub fn toMatrix4x4(self: Self) Matrix4x4 {
            assert(self.isNormalized());

            const w = self.w;
            const x = self.x;
            const y = self.y;
            const z = self.z;
            return .{
                .x = .{ .x = 1 - 2 * y * y - 2 * z * z, .y = 2 * x * y - 2 * w * z, .z = 2 * x * z + 2 * w * y, .w = 0 },
                .y = .{ .x = 2 * x * y + 2 * w * z, .y = 1 - 2 * x * x - 2 * z * z, .z = 2 * y * z - 2 * w * x, .w = 0 },
                .z = .{ .x = 2 * x * z - 2 * w * y, .y = 2 * y * z + 2 * w * x, .z = 1 - 2 * x * x - 2 * y * y, .w = 0 },
                .w = .{ .x = 0, .y = 0, .z = 0, .w = 1 },
            };
        }

        pub fn eulerAngles(self: Self) Vector3 {
            const pitch = math.atan2(2 * (self.w * self.x + self.y * self.z), 1 - 2 * (self.x * self.x + self.y * self.y));
            const roll = math.asin(2 * (self.w * self.y - self.x * self.z));
            const yaw = math.atan2(2 * (self.w * self.z + self.x * self.y), 1 - 2 * (self.y * self.y + self.z * self.z));
            return .{ .x = pitch, .y = roll, .z = yaw };
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try formatGeneric(self, T, 4, 1, fmt, options, writer);
        }
    };
}
