
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

            const sin = math.sin(angle / 2.0);
            const cos = math.cos(angle / 2.0);

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
                .y = self.w * other.y + self.y * other.w + self.z * other.x - self.x * other.z,
                .z = self.w * other.z + self.z * other.w + self.x * other.y - self.y * other.x,
                .w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z
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

        pub fn eulerAngles(self: Self) Vector {

            const pitch = math.atan2(
                2 * (self.w * self.x + self.y * self.z),
                1 - 2 * (self.x * self.x + self.y * self.y)
            );

            const roll = math.asin(2 * (self.w * self.y - self.x * self.z));

            const yaw = math.atan2(
                2 * (self.w * self.z + self.x * self.y),
                1 - 2 * (self.y * self.y + self.z * self.z)
            );

            return .{
                .x = pitch,
                .y = roll,
                .z = yaw
            };
        }
    

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        
            _ = fmt;

            const ff = std.fmt.format_float;

            const valueOptions = ff.FormatOptions {
                .mode = .decimal,
                .precision = options.precision
            };

            var buffer: [ff.min_buffer_size]u8 = undefined;
            var slice: []const u8 = undefined;

            _ = try writer.write("(");
            slice = try std.fmt.formatFloat(&buffer, self.x, valueOptions);
            _ = try writer.write(slice);
            _ = try writer.write(", ");
            slice = try std.fmt.formatFloat(&buffer, self.y, valueOptions);
            _ = try writer.write(slice);
            _ = try writer.write(", ");
            slice = try std.fmt.formatFloat(&buffer, self.z, valueOptions);
            _ = try writer.write(slice);
            _ = try writer.write(", ");
            slice = try std.fmt.formatFloat(&buffer, self.w, valueOptions);
            _ = try writer.write(slice);
            _ = try writer.write(")");
        }
    };
}
