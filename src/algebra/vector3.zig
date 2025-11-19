const std = @import("std");
const math = std.math;
const quaternion = @import("quaternion.zig");
const assert = std.debug.assert;


pub fn Vector3(T: type) type {

    comptime switch (@typeInfo(T)) {
        // some operations will not work for int!
        .int => {},
        .float,=> {},
        else => @compileError("Vector elements must be a number type")
    };

    return struct {

        const Quaternion = quaternion.Quaternion(T);

        const Self = @This();

        pub const zero = Self.all(0);
        pub const one = Self.all(1);

        pub const axis = struct {
            pub const x = Self.of(1, 0, 0);
            pub const y = Self.of(0, 1, 0);
            pub const z = Self.of(0, 0, 1);
        };

        x: T,
        y: T,
        z: T,

        pub fn of(x: T, y: T, z: T) Self {
            return .{
                .x = x,
                .y = y,
                .z = z
            };
        }

        /// create a vector with all components set to the given value
        pub fn all(value: T) Self {
            return of(value, value, value);
        }

        /// add vector elements
        pub fn add(self: Self, other: Self) Self {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
                .z = self.z + other.z
            };
        }

        /// subtract vector elements
        pub fn subtract(self: Self, other: Self) Self {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y,
                .z = self.z - other.z
            };
        }

        /// multiplytiply vector elements
        pub fn multiply(self: Self, other: Self) Self {
            return .{
                .x = self.x * other.x,
                .y = self.y * other.y,
                .z = self.z * other.z
            };
        }

        /// multiply all elements by scalar value
        pub fn times(self: Self, factor: T) Self {
            return .{
                .x = self.x * factor,
                .y = self.y * factor,
                .z = self.z * factor
            };
        }

        /// divide by vector elements
        pub fn divide(self: Self, other: Self) Self {
            return .{
                .x = self.x / other.x,
                .y = self.y / other.y,
                .z = self.z / other.z
            };
        }

        pub fn rotate(self: Self, rotation: Quaternion) Self {
            return rotation.apply(self);
        }

        /// dot product
        pub fn dot(self: Self, other: Self) T {
            return self.x * other.x + self.y * other.y + self.z * other.z;
        }

        /// cross product
        pub fn cross(self: Self, other: Self) Self {
            return .{
                .x = self.y * other.z - self.z * other.y,
                .y = self.z * other.x - self.x * other.z,
                .z = self.x * other.y - self.y * other.x
            };
        }

        pub fn distance(self: Self, other: Self) T {
            return other.subtract(self).length();
        }

        pub fn length(self: Self) T {
            return math.sqrt(self.lengthSquared());
        }

        pub fn lengthSquared(self: Self) T {
            return self.x * self.x + self.y * self.y + self.z * self.z;
        }

        pub fn isNormalized(self: Self) bool {
            return math.approxEqAbs(T, self.lengthSquared() - 1, 0, 1e-5);
        }

        pub fn normalize(self: Self) error{CloseToZero}!Self {

            const len = self.length();
            if(math.approxEqAbs(T, len, 0, math.floatEps(T))) {
                return error.CloseToZero;
            }

            return self.times(1 / len);
        }

        pub fn inverse(self: Self) Self {
            return self.times(-1);
        }

        /// convert to 2 dimensional vector, ignoring the z component
        pub fn toVector2(self: Self) @import("vector2.zig").Vector2(T) {
            return .{
                .x = self.x,
                .y = self.y
            };
        }

        pub fn format(self: Self, writer: *std.Io.Writer) std.Io.Writer.Error!void {
            try writer.print("({d:.4}, {d:.4}, {d:.4})", .{ self.x, self.y, self.z });
        }
    };
}

const testing = std.testing;
const Vec = Vector3(f32);
const tolerance = math.floatEps(f32);

test "all" {

    const a = Vec.all(1.0);

    try testing.expectApproxEqRel(1.0, a.x, tolerance);
    try testing.expectApproxEqRel(1.0, a.y, tolerance);
    try testing.expectApproxEqRel(1.0, a.z, tolerance);
}

test "add" {

    const a = Vec.of(1.0, 0.0, 0.0);
    const b = Vec.of(1.5, -1.0, 0.0);
    const c = a.add(b);

    try testing.expectApproxEqRel(2.5, c.x, tolerance);
    try testing.expectApproxEqRel(-1.0, c.y, tolerance);
    try testing.expectApproxEqRel(0.0, c.z, tolerance);
}

test "subtract" {

    const a = Vec.of(1.0, 0.0, 0.0);
    const b = Vec.of(1.5, -1.0, 0.0);
    const c = a.subtract(b);

    try testing.expectApproxEqRel(-0.5, c.x, tolerance);
    try testing.expectApproxEqRel(1.0, c.y, tolerance);
    try testing.expectApproxEqRel(0.0, c.z, tolerance);
}

test "multiply" {

    const a = Vec.of(1.0, 4.0, 0.0);
    const b = Vec.of(1.5, -1.0, 0.0);
    const c = a.multiply(b);

    try testing.expectApproxEqRel(1.5, c.x, tolerance);
    try testing.expectApproxEqRel(-4.0, c.y, tolerance);
    try testing.expectApproxEqRel(0.0, c.z, tolerance);
}

test "times" {

    const a = Vec.of(1.5, 4.0, -3.0);
    const b = a.times(2.0);

    try testing.expectApproxEqRel(3.0, b.x, tolerance);
    try testing.expectApproxEqRel(8.0, b.y, tolerance);
    try testing.expectApproxEqRel(-6.0, b.z, tolerance);
}

test "divide" {

    const a = Vec.of(4.0, 1.0, 0.0);
    const b = Vec.of(2.0, 0.25, 0.0);
    const c = a.divide(b);

    try testing.expectApproxEqRel(2.0, c.x, tolerance);
    try testing.expectApproxEqRel(4.0, c.y, tolerance);
    try testing.expect(math.isNan(c.z));
}

test "dot" {

    const a = Vec.of(4.0, 1.0, 0.0);
    const b = Vec.of(2.0, 0.25, 0.0);
    const c = a.dot(b);

    try testing.expectApproxEqRel(8.25, c, tolerance);
}

test "cross" {

    const a = Vec.of(1.0, 0.0, 0.0);
    const b = Vec.of(0.0, 1.0, 0.0);
    const c = a.cross(b);

    try testing.expectApproxEqRel(0.0, c.x, tolerance);
    try testing.expectApproxEqRel(0.0, c.y, tolerance);
    try testing.expectApproxEqRel(1.0, c.z, tolerance);
}

test "distance" {

    const a = Vec.of(4.0, 0.0, 0.0);
    const b = Vec.of(4.0, 6.0, 0.0);

    try testing.expectApproxEqRel(6.0, a.distance(b), tolerance);
    try testing.expectApproxEqRel(6.0, b.distance(a), tolerance);
}

test "length" {

    const a = Vec.of(4.0, 0.0, 0.0);
    try testing.expectApproxEqRel(4.0, a.length(), tolerance);

    const b = Vec.of(3.0, 4.0, 0.0);
    try testing.expectApproxEqRel(5.0, b.length(), tolerance);
}

test "normalize" {

    const a = Vec.of(1.0, 0.0, 0.0);
    try testing.expect(a.isNormalized());

    const b = Vec.of(3.0, 4.0, -5.0);
    try testing.expect(!b.isNormalized());

    const c = try b.normalize();
    try testing.expect(c.isNormalized());
}

test "toVector2" {

    const a = Vec.of(1.0, 2.0, 3.0);
    const b = a.toVector2();

    try testing.expectApproxEqRel(1.0, b.x, tolerance);
    try testing.expectApproxEqRel(2.0, b.y, tolerance);
}