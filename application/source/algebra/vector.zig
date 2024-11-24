const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const matrix = @import("matrix.zig");

pub fn Vector3D(comptime T: type) type {
    
    return struct {

        const Self = @This();

        x: T,
        y: T,
        z: T,

        pub inline fn of(x: T, y: T, z: T) Self {
            return .{ .x = x, .y = y, .z = z };
        }

        pub inline fn all(value: T) Self {
            return .{ .x = value, .y = value, .z = value };
        }

        pub fn dot(self: Self, other: Self) T {
            return self.x * other.x + self.y * other.y + self.z * other.z;
        }

        pub fn cross(self: Self, other: Self) Self {
            return .{
                .x = self.y * other.z - other.y * self.z,
                .y = self.z * other.x - other.z * self.x,
                .z = self.x * other.y - other.x * self.y,
            };    
        }

        pub fn isNormalized(self: Self) bool {
            return @abs(self.lengthSquared() - 1.0) <= 1e-4;
        }

        pub fn normalize(self: Self) Self {

            const reciprocal = 1.0 / self.length();
            assert(reciprocal > 0.0);
            return self.multiply(Self.all(reciprocal));
        }

        pub fn add(self: Self, other: Self) Self {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
                .z = self.z + other.z
            };
        }

        pub fn multiply(self: Self, other: Self) Self {
            return .{
                .x = self.x * other.x,
                .y = self.y * other.y,
                .z = self.z * other.z
            };
        }

        pub fn scale(self: Self, value: T) Self {
            return .{
                .x = self.x * value,
                .y = self.y * value,
                .z = self.z * value
            };
        }

        pub fn opposite(self: Self) Self {
            return self.scale(-1);
        }

        pub fn length(self: Self) T {
            return math.sqrt(self.lengthSquared());
        }

        fn lengthSquared(self: Self) T {
            return self.dot(self);
        }

        const Matrix4x1 = matrix.Matrix(T).Sized(4, 1);

        pub fn toMatrix4x1(self: Self, w: T) Matrix4x1 {
            
            var m = Matrix4x1.zeros();
            m.setColumn(0, .{
                self.x,
                self.y,
                self.z,
                w
            });
            return m;
        }
    };
}
