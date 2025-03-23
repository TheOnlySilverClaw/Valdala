const std = @import("std");
const assert = std.debug.assert;
const vector = @import("vector.zig");
const Vector2 = vector.Vector2;
const Vector3 = vector.Vector3;
const Vector4 = vector.Vector4;
const formatGeneric = @import("module.zig").formatGeneric;

/// Column major -- index by mat.col.row. This ensures WGSL and GLSL compatible memory layout
pub fn Matrix2x2(comptime T: type) type {
    return extern struct {
        x: Vector2(T),
        y: Vector2(T),
        const Self = @This();

        pub const identity: Self = .{
            .x = .{ .x = 1, .y = 0 },
            .y = .{ .x = 0, .y = 1 },
        };

        pub const zeros: Self = .{
            .x = .{ .x = 0, .y = 0 },
            .y = .{ .x = 0, .y = 0 },
        };

        pub fn multiply(ma: *const Self, mb: *const Self) Self {
            return .{
                .x = .{ .x = ma.x.x * mb.x.x + ma.y.x * mb.x.y, .y = ma.x.y * mb.x.x + ma.y.y * mb.x.y },
                .y = .{ .x = ma.x.x * mb.y.x + ma.y.x * mb.y.y, .y = ma.x.y * mb.y.x + ma.y.y * mb.y.y },
            };
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try formatGeneric(self, T, 2, 2, fmt, options, writer);
        }
    };
}

/// Column major -- index by mat.col.row. This ensures WGSL and GLSL compatible memory layout
pub fn Matrix3x3(comptime T: type) type {
    return extern struct {
        x: Vector3(T),
        y: Vector3(T),
        z: Vector3(T),
        const Self = @This();

        pub const identity: Self = .{
            .x = .{ .x = 1, .y = 0, .z = 0 },
            .y = .{ .x = 0, .y = 1, .z = 0 },
            .z = .{ .x = 0, .y = 0, .z = 1 },
        };

        pub const zeros: Self = .{
            .x = .{ .x = 0, .y = 0, .z = 0 },
            .y = .{ .x = 0, .y = 0, .z = 0 },
            .z = .{ .x = 0, .y = 0, .z = 0 },
        };

        pub fn multiply(ma: *const Self, mb: *const Self) Self {
            return .{
                .x = .{
                    .x = ma.x.x * mb.x.x + ma.y.x * mb.x.y + ma.z.x * mb.x.z,
                    .y = ma.x.y * mb.x.x + ma.y.y * mb.x.y + ma.z.y * mb.x.z,
                    .z = ma.x.z * mb.x.x + ma.y.z * mb.x.y + ma.z.z * mb.x.z,
                },
                .y = .{
                    .x = ma.x.x * mb.y.x + ma.y.x * mb.y.y + ma.z.x * mb.y.z,
                    .y = ma.x.y * mb.y.x + ma.y.y * mb.y.y + ma.z.y * mb.y.z,
                    .z = ma.x.z * mb.y.x + ma.y.z * mb.y.y + ma.z.z * mb.y.z,
                },
                .z = .{
                    .x = ma.x.x * mb.z.x + ma.y.x * mb.z.y + ma.z.x * mb.z.z,
                    .y = ma.x.y * mb.z.x + ma.y.y * mb.z.y + ma.z.y * mb.z.z,
                    .z = ma.x.z * mb.z.x + ma.y.z * mb.z.y + ma.z.z * mb.z.z,
                },
            };
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try formatGeneric(self, T, 3, 3, fmt, options, writer);
        }
    };
}

/// Column major -- index by mat.col.row. This ensures WGSL and GLSL compatible memory layout
pub fn Matrix4x4(comptime T: type) type {
    return extern struct {
        x: Vector4(T),
        y: Vector4(T),
        z: Vector4(T),
        w: Vector4(T),
        const Self = @This();

        pub const identity: Self = .{
            .x = .{ .x = 1, .y = 0, .z = 0, .w = 0 },
            .y = .{ .x = 0, .y = 1, .z = 0, .w = 0 },
            .z = .{ .x = 0, .y = 0, .z = 1, .w = 0 },
            .w = .{ .x = 0, .y = 0, .z = 0, .w = 1 },
        };

        pub const zeros: Self = .{
            .x = .{ .x = 0, .y = 0, .z = 0, .w = 0 },
            .y = .{ .x = 0, .y = 0, .z = 0, .w = 0 },
            .z = .{ .x = 0, .y = 0, .z = 0, .w = 0 },
            .w = .{ .x = 0, .y = 0, .z = 0, .w = 0 },
        };

        pub fn asArray(self: *Self) *[16]T {
            return @ptrCast(self);
        }

        pub fn as2DArray(self: *Self) *[4][4]T {
            return @ptrCast(self);
        }

        pub fn get(self: *const Self, column: comptime_int, row: comptime_int) T {
            return self.as2DArray()[column][row];
        }

        pub fn set(self: *Self, column: comptime_int, row: comptime_int, value: T) void {
            self.as2DArray()[column][row] = value;
        }

        pub fn transposed(self: Self) Self {
            return .{
                .x = .{ .x = self.x.x, .y = self.y.x, .z = self.z.x, .w = self.w.x },
                .y = .{ .x = self.x.y, .y = self.y.y, .z = self.z.y, .w = self.w.y },
                .z = .{ .x = self.x.z, .y = self.y.z, .z = self.z.z, .w = self.w.z },
                .w = .{ .x = self.x.w, .y = self.y.w, .z = self.z.w, .w = self.w.w },
            };
        }

        pub fn multiply(ma: *const Self, mb: *const Self) Self {
            return .{
                .x = .{
                    .x = ma.x.x * mb.x.x + ma.y.x * mb.x.y + ma.z.x * mb.x.z + ma.w.x * mb.x.w,
                    .y = ma.x.y * mb.x.x + ma.y.y * mb.x.y + ma.z.y * mb.x.z + ma.w.y * mb.x.w,
                    .z = ma.x.z * mb.x.x + ma.y.z * mb.x.y + ma.z.z * mb.x.z + ma.w.z * mb.x.w,
                    .w = ma.x.w * mb.x.x + ma.y.w * mb.x.y + ma.z.w * mb.x.z + ma.w.w * mb.x.w,
                },
                .y = .{
                    .x = ma.x.x * mb.y.x + ma.y.x * mb.y.y + ma.z.x * mb.y.z + ma.w.x * mb.y.w,
                    .y = ma.x.y * mb.y.x + ma.y.y * mb.y.y + ma.z.y * mb.y.z + ma.w.y * mb.y.w,
                    .z = ma.x.z * mb.y.x + ma.y.z * mb.y.y + ma.z.z * mb.y.z + ma.w.z * mb.y.w,
                    .w = ma.x.w * mb.y.x + ma.y.w * mb.y.y + ma.z.w * mb.y.z + ma.w.w * mb.y.w,
                },
                .z = .{
                    .x = ma.x.x * mb.z.x + ma.y.x * mb.z.y + ma.z.x * mb.z.z + ma.w.x * mb.z.w,
                    .y = ma.x.y * mb.z.x + ma.y.y * mb.z.y + ma.z.y * mb.z.z + ma.w.y * mb.z.w,
                    .z = ma.x.z * mb.z.x + ma.y.z * mb.z.y + ma.z.z * mb.z.z + ma.w.z * mb.z.w,
                    .w = ma.x.w * mb.z.x + ma.y.w * mb.z.y + ma.z.w * mb.z.z + ma.w.w * mb.z.w,
                },
                .w = .{
                    .x = ma.x.x * mb.w.x + ma.y.x * mb.w.y + ma.z.x * mb.w.z + ma.w.x * mb.w.w,
                    .y = ma.x.y * mb.w.x + ma.y.y * mb.w.y + ma.z.y * mb.w.z + ma.w.y * mb.w.w,
                    .z = ma.x.z * mb.w.x + ma.y.z * mb.w.y + ma.z.z * mb.w.z + ma.w.z * mb.w.w,
                    .w = ma.x.w * mb.w.x + ma.y.w * mb.w.y + ma.z.w * mb.w.z + ma.w.w * mb.w.w,
                },
            };
        }

        pub fn add(m1: *const Self, m2: *const Self) Self {
            return .{
                .x = .{ .x = m1.x.x + m2.x.x, .y = m1.x.y + m2.x.y, .z = m1.x.z + m2.x.z, .w = m1.x.w + m2.x.w },
                .y = .{ .x = m1.y.x + m2.y.x, .y = m1.y.y + m2.y.y, .z = m1.y.z + m2.y.z, .w = m1.y.w + m2.y.w },
                .z = .{ .x = m1.z.x + m2.z.x, .y = m1.z.y + m2.z.y, .z = m1.z.z + m2.z.z, .w = m1.z.w + m2.z.w },
                .w = .{ .x = m1.w.x + m2.w.x, .y = m1.w.y + m2.w.y, .z = m1.w.z + m2.w.z, .w = m1.w.w + m2.w.w },
            };
        }

        pub fn multiplyVector4(m: Self, v: Vector4(T)) Vector4(T) {
            _ = m;
            _ = v;
        }

        pub fn translation(v: Vector3(T)) Self {
            return .{
                .x = .{ .x = 1, .y = 0, .z = 0, .w = 0 },
                .y = .{ .x = 0, .y = 1, .z = 0, .w = 0 },
                .z = .{ .x = 0, .y = 0, .z = 1, .w = 0 },
                .w = .{ .x = v.x, .y = v.y, .z = v.z, .w = 1 },
            };
        }

        /// Returns a new matrix obtained by translating the input one.
        pub fn translate(self: Self, v: Vector3(T)) Self {
            return .{
                .x = self.x,
                .y = self.y,
                .z = self.z,
                .w = self.w.add(.{ .x = v.x, .y = v.y, .z = v.z, .w = 1 }),
            };
        }

        // TODO: maybe move this to camera module
        /// Right-handed y up, zero to one clipping space.
        pub fn perspective(fovy_rad: T, aspect: T, near: T, far: T) Self {
            const f = 1.0 / @tan(fovy_rad / 2.0);
            return .{
                .x = .{ .x = f / aspect, .y = 0, .z = 0, .w = 0 },
                .y = .{ .x = 0, .y = f, .z = 0, .w = 0 },
                .z = .{ .x = 0, .y = 0, .z = far / (far - near), .w = 1 },
                .w = .{ .x = 0, .y = 0, .z = -(far * near) / (far - near), .w = 0 },
            };
        }

        // TODO: Add a faster version that assume the axis is normalized.
        /// Create a rotation matrix around an arbitrary axis.
        pub fn rotation(axis: Vector3(T), angle_rad: T) Self {
            const c = @cos(angle_rad);
            const s = @sin(angle_rad);
            const t = 1.0 - c;

            const sqr_norm = axis.squaredNorm();
            if (sqr_norm == 0.0) {
                return Self.identity;
            } else if (@abs(sqr_norm - 1.0) > 0.0001) {
                const norm = @sqrt(sqr_norm);
                return rotation(axis.div(norm), angle_rad);
            }

            const x = axis.x;
            const y = axis.y;
            const z = axis.z;

            return .{
                .x = .{ .x = x * x * t + c, .y = y * x * t + z * s, .z = z * x * t - y * s, .w = 0 },
                .y = .{ .x = x * y * t - z * s, .y = y * y * t + c, .z = z * y * t + x * s, .w = 0 },
                .z = .{ .x = x * z * t + y * s, .y = y * z * t - x * s, .z = z * z * t + c, .w = 0 },
                .w = .{ .x = 0, .y = 0, .z = 0, .w = 1 },
            };
        }

        ///Rotates a matrix around an arbitrary axis.
        pub fn rotate(self: Self, axis: Vector3(T), angle_rad: T) Self {
            return multiply(rotation(axis, angle_rad), self);
        }

        pub fn scaled(self: *const Self, v: *const Vector3(T)) Self {
            var m = self.*;
            m.x.x *= v.x;
            m.y.y *= v.y;
            m.z.z *= v.z;
            return m;
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try formatGeneric(self, T, 4, 4, fmt, options, writer);
        }
    };
}

// TODO: Consider removing this
/// Column major -- index by mat.col.row. This ensures WGSL and GLSL compatible memory layout
pub fn Matrix4x4SIMD(comptime T: type) type {
    return extern struct {
        x: @Vector(4, T),
        y: @Vector(4, T),
        z: @Vector(4, T),
        w: @Vector(4, T),
        const Self = @This();

        pub const identity: Self = .{
            .x = .{ 1, 0, 0, 0 },
            .y = .{ 0, 1, 0, 0 },
            .z = .{ 0, 0, 1, 0 },
            .w = .{ 0, 0, 0, 1 },
        };

        pub fn multiply(ma: *const Self, mb: *const Self) Self {
            // Transpose mb for better vector operations
            const mb_t = Self{
                .x = .{ mb.x[0], mb.y[0], mb.z[0], mb.w[0] },
                .y = .{ mb.x[1], mb.y[1], mb.z[1], mb.w[1] },
                .z = .{ mb.x[2], mb.y[2], mb.z[2], mb.w[2] },
                .w = .{ mb.x[3], mb.y[3], mb.z[3], mb.w[3] },
            };

            return .{
                .x = .{
                    @reduce(.Add, ma.x * mb_t.x),
                    @reduce(.Add, ma.x * mb_t.y),
                    @reduce(.Add, ma.x * mb_t.z),
                    @reduce(.Add, ma.x * mb_t.w),
                },
                .y = .{
                    @reduce(.Add, ma.y * mb_t.x),
                    @reduce(.Add, ma.y * mb_t.y),
                    @reduce(.Add, ma.y * mb_t.z),
                    @reduce(.Add, ma.y * mb_t.w),
                },
                .z = .{
                    @reduce(.Add, ma.z * mb_t.x),
                    @reduce(.Add, ma.z * mb_t.y),
                    @reduce(.Add, ma.z * mb_t.z),
                    @reduce(.Add, ma.z * mb_t.w),
                },
                .w = .{
                    @reduce(.Add, ma.w * mb_t.x),
                    @reduce(.Add, ma.w * mb_t.y),
                    @reduce(.Add, ma.w * mb_t.z),
                    @reduce(.Add, ma.w * mb_t.w),
                },
            };
        }
    };
}

/// Column major -- index by mat.col.row. This ensures WGSL and GLSL compatible memory layout
pub fn Matrix(comptime T: type, columns: comptime_int, rows: comptime_int) type {
    return extern struct {
        values: [C][R]T,
        const Self = @This();
        pub const C = columns;
        pub const R = rows;

        pub const zeros: Self = .{ .values = .{.{0} ** R} ** C };

        pub fn identity() Self {
            var m = zeros;
            m.setDiagonal(.{1.0} ** C);
            return m;
        }

        pub fn ofValue(value: T) Self {
            return .{ .values = .{.{value} ** R} ** C };
        }

        pub fn ofValues(values: [C][R]T) Self {
            return .{
                .values = values,
            };
        }

        pub fn setColumn(self: *Self, column: u32, values: [R]T) void {
            for (0..R) |row| {
                self.values[column][row] = values[row];
            }
        }

        pub fn setRow(self: *Self, row: u32, values: [C]T) void {
            for (0..C) |column| {
                self.values[column][row] = values[column];
            }
        }

        pub fn setDiagonal(self: *Self, values: [C]T) void {
            comptime std.debug.assert(C == R);

            for (0..C) |diagonal| {
                self.values[diagonal][diagonal] = values[diagonal];
            }
        }

        pub fn isDiagonal() bool {
            return C == R;
        }

        pub fn transposed(self: Self) Self {
            comptime std.debug.assert(Self.isDiagonal());

            var new: Self = undefined;
            for (0..R) |row| {
                for (0..C) |column| {
                    new.values[row][column] = self.values[column][row];
                }
            }
            return new;
        }

        pub fn add(self: Self, other: Self) Self {
            var new: Self = undefined;
            for (&new.values, self.values, other.values) |*value, a, b| {
                value.* = a + b;
            }
            return new;
        }

        pub fn scale(self: Self, scalar: T) Self {
            var new = self;
            for (&new.values) |*value| {
                value.* = scalar * value.*;
            }
            return new;
        }

        pub fn multiply(self: *const Self, other: anytype) Matrix(T, C, R) {
            const Other = @TypeOf(other);
            comptime if (Self.C != Other.R) {
                @compileError("Matrix multiplytiplication shape mismatch");
            };
            const New = Matrix(T, C, R);
            var new: New = undefined;
            for (0..R) |row| {
                for (0..Other.C) |column| {
                    var sum: T = 0;
                    for (0..C) |i| {
                        const a = self.values[i][row];
                        const b = other.values[column][i];
                        sum = sum + a * b;
                    }
                    new.values[column][row] = sum;
                }
            }
            return new;
        }

        pub fn format(self: Self, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            try formatGeneric(self, T, C, R, fmt, options, writer);
        }
    };
}
