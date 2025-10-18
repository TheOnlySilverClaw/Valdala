const std = @import("std");
const math = std.math;
const assert = std.debug.assert;

pub fn Vector2(T: type) type {

    comptime switch (@typeInfo(T)) {
        // some operations will not work for int!
        .int => {},
        .float,=> {},
        else => @compileError("Vector elements must be a number type")
    };

    return struct {

        const Self = @This();

        pub const zero = Self.of(0, 0);

        x: T,
        y: T,

        pub fn of(x: T, y: T) Self {
            return .{
                .x = x,
                .y = y
            };
        }

        /// add vector elements
        pub fn add(self: Self, other: Self) Self {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y
            };
        }

        /// subtract vector elements
        pub fn subtract(self: Self, other: Self) Self {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y
            };
        }

        /// multiply vector elements
        pub fn multiply(self: Self, other: Self) Self {
            return .{
                .x = self.x * other.x,
                .y = self.y * other.y
            };
        }

        /// multiply all elements by scalar value
        pub fn times(self: Self, factor: T) Self {
            return .{
                .x = self.x * factor,
                .y = self.y * factor
            };
        }

        pub fn opposite(self: Self) Self {
            return self.times(-1);
        }

        /// divide by vector elements
        pub fn divide(self: Self, other: Self) Self {
            return .{
                .x = self.x / other.x,
                .y = self.y / other.y
            };
        }

        /// dot product
        pub fn dot(self: Self, other: Self) T {
            return self.x * other.x + self.y * other.y;
        }

        pub fn distance(self: Self, other: Self) T {
            return other.subtract(self).length();
        }

        pub fn length(self: Self) T {
            return math.sqrt(self.lengthSquared());
        }

        pub fn lengthSquared(self: Self) T {
            return self.x * self.x + self.y * self.y;
        }

        pub fn isNormalized(self: Self) bool {
            return math.approxEqAbs(T, self.lengthSquared() - 1, 0, math.floatEps(T));
        }

        pub fn normalize(self: Self) error{CloseToZero}!Self {

            const len = self.length();
            if(math.approxEqAbs(T, len, 0, math.floatEps(T))) {
                return error.CloseToZero;
            }

            return self.times(1 / len);
        }

        /// convert to 3 dimensional vector with z = 0
        pub fn toVector3(self: Self) @import("vector3.zig").Vector3(T) {
            return .{
                .x = self.x,
                .y = self.y,
                .z = 0
            };
        }

        pub fn format(self: Self, writer: *std.Io.Writer) std.Io.Writer.Error!void {
            try writer.print("({d:.4}, {d:.4})", .{ self.x, self.y });
        }
    };
}

const testing = std.testing;
const Vec = Vector2(f32);
const tolerance = math.floatEps(f32);

test "add" {

    const a = Vec.of(1.0, 0.0);
    const b = Vec.of(1.5, -1.0);
    const c = a.add(b);

    try testing.expectApproxEqRel(2.5, c.x, tolerance);
    try testing.expectApproxEqRel(-1.0, c.y, tolerance);
}

test "subtract" {

    const a = Vec.of(1.0, 0.0);
    const b = Vec.of(1.5, -1.0);
    const c = a.subtract(b);

    try testing.expectApproxEqRel(-0.5, c.x, tolerance);
    try testing.expectApproxEqRel(1.0, c.y, tolerance);
}

test "multiply" {

    const a = Vec.of(1.0, 4.0);
    const b = Vec.of(1.5, -1.0);
    const c = a.multiply(b);

    try testing.expectApproxEqRel(1.5, c.x, tolerance);
    try testing.expectApproxEqRel(-4.0, c.y, tolerance);
}

test "divide" {

    const a = Vec.of(4.0, 1.0);
    const b = Vec.of(2.0, 0.25);
    const c = a.divide(b);

    try testing.expectApproxEqRel(2.0, c.x, tolerance);
    try testing.expectApproxEqRel(4.0, c.y, tolerance);
}

test "dot" {

    const a = Vec.of(4.0, 1.0);
    const b = Vec.of(2.0, 0.25);
    const c = a.dot(b);

    try testing.expectApproxEqRel(8.25, c, tolerance);
}

test "distance" {

    const a = Vec.of(4.0, 0.0);
    const b = Vec.of(4.0, 6.0);

    try testing.expectApproxEqRel(6.0, a.distance(b), tolerance);
    try testing.expectApproxEqRel(6.0, b.distance(a), tolerance);
}

test "length" {

    const a = Vec.of(4.0, 0.0);
    try testing.expectApproxEqRel(4.0, a.length(), tolerance);

    const b = Vec.of(3.0, 4.0);
    try testing.expectApproxEqRel(5.0, b.length(), tolerance);
}

test "normalize" {

    const a = Vec.of(1.0, 0.0);
    try testing.expect(a.isNormalized());

    const b = Vec.of(3.0, 4.0);
    try testing.expect(!b.isNormalized());

    const c = try b.normalize();
    try testing.expect(c.isNormalized());
}

test "toVector3" {

    const a = Vec.of(1.0, 2.0);
    const b = a.toVector3();

    try testing.expectApproxEqRel(1.0, b.x, tolerance);
    try testing.expectApproxEqRel(2.0, b.y, tolerance);
    try testing.expectApproxEqRel(0.0, b.z, tolerance);
}