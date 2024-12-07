
const std = @import("std");
const math = std.math;
const assert = std.debug.assert;

pub fn Quaternion(comptime T: type) type {

    const Vector = @import("vector.zig").Vector3D(T);
    const Matrix = @import("matrix.zig").Matrix(T).Sized(4, 4);
    
    return struct {
        
        const Self = @This();
        
        x: T,
        y: T,
        z: T,
        w: T,

        pub fn identity() Self {
            return .{ .x = 0, .y = 0, .z = 0, .w = 1 };
        }

        pub fn aroundAxis(axis: Vector, angle: T) Self {

            const half = angle * 0.5;
            const sin = math.sin(half);
            const cos = math.cos(half);

            return .{
                .x = axis.x * sin,
                .y = axis.y * sin,
                .z = axis.z * sin,
                .w = cos,
            };
        }

        pub fn add(self: Self, other: Self) Self {
            return .{
                .x = self.x + other.x,
                .y = self.x + other.y,
                .z = self.x + other.z,
                .w = self.x + other.w,
            };
        }

        pub fn multiply(self: Self, other: Self) Self {

            assert(self.isNormalized());
            assert(other.isNormalized());

            const result = Self {
                .x = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y,
                .y = self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x,
                .z = self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w,
                .w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z,
            };
            return result.normalize();
        }

        pub fn rotate(self: Self, position: Vector) Vector {
            
            assert(self.isNormalized());

            const w = self.w;
            const axis = Vector.of(self.x, self.y, self.z);

            return position.scaleUniform(w * w - axis.dot(axis))
                .add(axis.scaleUniform(position.dot(axis) * 2.0))
                .add(axis.cross(position).scaleUniform(w * 2.0))
                .normalize();
        }

        pub fn inverse(self: Self) Self {
            assert(self.isNormalized());
            return self.conjugate();
        }

        pub fn conjugate(self: Self) Self {
            return .{
                .x = -self.x,
                .y = -self.y,
                .z = -self.z,
                .w = self.w
            };
        }

        pub fn dot(self: Self, other: Self) T {
            return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;
        }

        pub fn normalize(self: Self) Self {

            const reciprocal = 1.0 / self.length();
            assert(reciprocal > 0.0);
            return .{
                .x = self.x * reciprocal,
                .y = self.y * reciprocal,
                .z = self.z * reciprocal,
                .w = self.w * reciprocal
            };
        }

        pub fn isNormalized(self: Self) bool {
            return @abs(self.lengthSquared() - 1.0) <= 1e-4;
        }

        pub fn length(self: Self) T {
            return math.sqrt(self.lengthSquared());
        }

        fn lengthSquared(self: Self) T {
            return self.dot(self);
        }

        pub fn matrix(self: Self) Matrix {

            assert(self.isNormalized());
            
            const w = self.w;
            const x = self.x;
            const y = self.y;
            const z = self.z;

            var m = Matrix.zeros();
            
            m.set(0, 0, w * w  + x * x - y * y - z * z);
            m.set(1, 0, 2 * x * y - 2 * w * z);
            m.set(2, 0, 2 * x * z + 2 * w * y);

            m.set(0, 1, 2 * x * y + 2 * w * z);
            m.set(1, 1, w * w - x * x + y * y - z * z);
            m.set(2, 1, 2 * y * z - 2 * w * x);

            m.set(0, 2, 2 * x * z - 2 * w * y);
            m.set(1, 2, 2 * y * z + 2 * w * x);
            m.set(2, 2, w * w - x * x - y * y + z * z);

            m.set(3, 3, 1);

            return m;
        }
    };
}
