const std = @import("std");
const math = std.math;
const matrix = @import("matrix.zig");
const vector = @import("vector3.zig");

const assert = std.debug.assert;


pub fn Quaternion(comptime T: type) type {

    if (@typeInfo(T) != .float) @compileError("Quaternion components must a float type");
    
    const Vector = @import("vector3.zig").Vector3(T);
    const Matrix = @import("matrix.zig").Matrix(T, 4, 4);

    return struct {
        w: T,
        x: T,
        y: T,
        z: T,

        const Self = @This();

        pub const identity: Self = .{ .w = 1, .x = 0, .y = 0, .z = 0 };

        pub fn aroundAxis(axis: Vector, angle: T) Self {
            
            assert(axis.isNormalized());
            
            const half_angle = angle / 2.0;
            const sin = math.sin(half_angle);
            const cos = math.cos(half_angle);
            
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
                .y = self.y + other.y,
                .z = self.z + other.z,
                .w = self.w + other.w,
            };
        }

        pub fn multiply(self: Self, other: Self) Self {
            
            assert(self.isNormalized());
            assert(other.isNormalized());

            const result: Self = .{
                .x = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y,
                .y = self.w * other.y + self.y * other.w + self.z * other.x - self.x * other.z,
                .z = self.w * other.z + self.z * other.w + self.x * other.y - self.y * other.x,
                .w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z,
            };
            return result.normalized();
        }

        pub fn rotate(self: Self, v: Vector) Vector {
            
            const w = self.w;
            const r: Vector = .{ .x = self.x, .y = self.y, .z = self.z };
            const t = r.cross(v).times(2.0);
            return v.add(t.times(w)).add(r.cross(t));
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
                .w = self.w,
            };
        }

        pub fn dot(self: Self, other: Self) T {
            return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;
        }

        pub fn normalized(self: Self) Self {
            const reciprocal = 1.0 / self.length();
            assert(reciprocal > 0.0);
            return .{
                .x = self.x * reciprocal,
                .y = self.y * reciprocal,
                .z = self.z * reciprocal,
                .w = self.w * reciprocal,
            };
        }

        pub fn isNormalized(self: Self) bool {
            return @abs(self.lengthSquared() - 1.0) <= 1e-4;
        }

        pub fn lengthSquared(self: Self) T {
            return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w;
        }

        pub fn length(self: Self) T {
            return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w);
        }

        pub fn toMatrix(self: Self) Matrix {
            
            assert(self.isNormalized());

            const w = self.w;
            const x = self.x;
            const y = self.y;
            const z = self.z;

            var m = Matrix.zero;

            m.set(0, 0, 1 - 2 * y * y - 2 * z * z);
            m.set(1, 0, 2 * x * y + 2 * w * z);
            m.set(2, 0, 2 * x * z - 2 * w * y);

            m.set(0, 1, 2 * x * y - 2 * w * z);
            m.set(1, 1, 1 - 2 * x * x - 2 * z * z);
            m.set(2, 1, 2 * y * z + 2 * w * x);

            m.set(0, 2, 2 * x * z + 2 * w * y);
            m.set(1, 2, 2 * y * z - 2 * w * x);
            m.set(2, 2, 1 - 2 * x * x - 2 * y * y);

            m.set(3, 3, 1);
            
            return m;
        }

        pub fn eulerAngles(self: Self) Vector {

            const pitch = math.atan2(2 * (self.w * self.x + self.y * self.z), 1 - 2 * (self.x * self.x + self.y * self.y));
            const roll = math.asin(2 * (self.w * self.y - self.x * self.z));
            const yaw = math.atan2(2 * (self.w * self.z + self.x * self.y), 1 - 2 * (self.y * self.y + self.z * self.z));
            
            return .{ .x = pitch, .y = roll, .z = yaw };
        }

        pub fn format(self: Self, writer: *std.Io.Writer) std.Io.Writer.Error!void {
            try writer.print("({d:.4}, {d:.4}, {d:.4}: {d:.4})", .{ self.x, self.y, self.z, self.w });
        }
    };
}
