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

        pub fn scaleUniform(self: Self, value: T) Self {
            return .{
                .x = self.x * value,
                .y = self.y * value,
                .z = self.z * value
            };
        }

        pub fn scaleBy(self: Self, dimensions: Self) Self {
            return .{
                .x = self.x * dimensions.x,
                .y = self.y * dimensions.y,
                .z = self.z * dimensions.z
            };
        }

        pub fn opposite(self: Self) Self {
            return self.scaleUniform(-1);
        }

        pub fn length(self: Self) T {
            return math.sqrt(self.lengthSquared());
        }

        fn lengthSquared(self: Self) T {
            return self.dot(self);
        }

        const Matrix1x4 = matrix.Matrix(T).Sized(1, 4);

        pub fn asMatrix4x1(self: Self, w: T) Matrix1x4 {
            
            var m = Matrix1x4.zeros();
            m.setColumn(0, .{
                self.x,
                self.y,
                self.z,
                w
            });
            return m;
        }

        pub inline fn asDirection(self: Self) Matrix1x4 {
            return self.asMatrix4x1(1);
        }

        pub inline fn asPoint(self: Self) Matrix1x4 {
            return self.asMatrix4x1(0);
        }

        pub fn print(self: Self) void {
            std.debug.print("({d}, {d}, {d})\n", .{self.x, self.y, self.z});
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
            _ = try writer.write(")");
        }
    };
}
