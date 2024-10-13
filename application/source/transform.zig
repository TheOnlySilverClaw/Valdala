const std = @import("std");
const math = std.math;
const assert = std.debug.assert;


pub const Vector3D = struct {
    x: f32,
    y: f32,
    z: f32,

    fn of(x: f32, y: f32, z: f32) Vector3D {
        return .{ .x = x, .y = y, .z = z };
    }

    fn all(value: f32) Vector3D {
        return .{ .x = value, .y = value, .z = value };
    }

    fn dot(self: Vector3D, other: Vector3D) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    fn cross(self: Vector3D, other: Vector3D) Vector3D {
        return .{
            .x = self.y * other.z - other.y * self.z,
            .y = self.z * other.x - other.z * self.x,
            .z = self.x * other.y - other.x * self.y,
        };    
    }

    fn is_normalized(self: Vector3D) bool {
        return @abs(self.length_squared() - 1.0) <= 1e-4;
    }

    fn rotate(self: Vector3D, rotation: Quaternion) Vector3D {
        return rotation.rotate(self);
    }

    fn normalize(self: Vector3D) Vector3D {

        const reciprocal = 1.0 / self.length();
        assert(reciprocal > 0.0);
        return self.multiply(Vector3D.all(reciprocal));
    }

    fn add(self: Vector3D, other: Vector3D) Vector3D {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z
        };
    }

    fn multiply(self: Vector3D, other: Vector3D) Vector3D {
        return .{
            .x = self.x * other.x,
            .y = self.y * other.y,
            .z = self.z * other.z
        };
    }

    fn multiplyAll(self: Vector3D, value: f32) Vector3D {
        return .{
            .x = self.x * value,
            .y = self.y * value,
            .z = self.z * value
        };
    }

    fn length(self: Vector3D) f32 {
        return math.sqrt(self.length_squared());
    }

    fn length_squared(self: Vector3D) f32 {
        return self.dot(self);
    }
};

pub const Axis = struct {
    const X: Vector3D = .{ .x = 1, .y = 0, .z = 0 };
    const Y: Vector3D = .{ .x = 0, .y = 1, .z = 0 };
    const Z: Vector3D = .{ .x = 0, .y = 0, .z = 1 };
};

pub const Quaternion = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    fn identity() Quaternion {
        return .{ .x = 0, .y = 0, .z = 0, .w = 1 };
    }

    fn aroundAxis(axis: Vector3D, angle: f32) Quaternion {

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

    fn add(self: Quaternion, other: Quaternion) Quaternion {
        return .{
            .x = self.x + other.x,
            .y = self.x + other.y,
            .z = self.x + other.z,
            .w = self.x + other.w,
        };
    }

    fn multiply(self: Quaternion, other: Quaternion) Quaternion {

        assert(self.is_normalized());
        assert(other.is_normalized());

        return .{
            .x = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y,
            .y = self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x,
            .z = self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w,
            .w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z,
        };    
    }

    fn rotate(self: Quaternion, position: Vector3D) Vector3D {
        
        assert(self.is_normalized());

        const w = self.w;
        const axis = Vector3D.of(self.x, self.y, self.z);

        return position.multiplyAll(w * w - axis.dot(axis))
            .add(axis.multiplyAll(position.dot(axis) * 2.0))
            .add(axis.cross(position).multiplyAll(w * 2.0));
    }

    fn inverse(self: Quaternion) Quaternion {
        assert(self.is_normalized());
        return self.conjugate();
    }

    fn conjugate(self: Quaternion) Quaternion {
        return .{
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
            .w = self.w
        };
    }

    fn dot(self: Quaternion, other: Quaternion) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;
    }

    fn normalize(self: Quaternion) Quaternion {

        const reciprocal = 1.0 / self.length();
        assert(reciprocal > 0.0);
        return .{
            .x = self.x * reciprocal,
            .y = self.y * reciprocal,
            .z = self.z * reciprocal,
            .w = self.w * reciprocal
        };
    }

    fn is_normalized(self: Quaternion) bool {
        return @abs(self.length_squared() - 1.0) <= 1e-4;
    }

    fn length(self: Quaternion) f32 {
        return math.sqrt(self.length_squared());
    }

    fn length_squared(self: Quaternion) f32 {
        return self.dot(self);
    }
};



const print = std.debug.print;

const expect = std.testing.expect;

fn expectClose(expected: anytype, actual: anytype) !void {
    
    const T = @TypeOf(expected);
    return switch (T) {
        f32 => try std.testing.expectApproxEqAbs(expected, actual, 1e-5),
        Vector3D => {
            try expectClose(expected.x, actual.x);
            try expectClose(expected.y, actual.y);
            try expectClose(expected.z, actual.z);
        },
        Quaternion => {
            try expectClose(expected.x, actual.x);
            try expectClose(expected.y, actual.y);
            try expectClose(expected.z, actual.z);
            try expectClose(expected.w, actual.w);
        },
        else => @compileError("unsupported type")
    };
}

const rad90: f32 = math.degreesToRadians(90.0);

test "vector add" {
    try expectClose(Vector3D.of(2, 3, 4),
        Vector3D.of(1, 2, 3).add(Vector3D.all(1)));
    try expectClose(Vector3D.of(-2, 2, 300),
        Vector3D.of(-1.5, 2.5, 300.5).add(Vector3D.all(-0.5)));
}

test "vector multiply" {
    try expectClose(Vector3D.of(2, 4, 6),
        Vector3D.all(2).multiply(Vector3D.of(1, 2, 3)));
    try expectClose(Vector3D.of(-1, 4, -9),
        Vector3D.of(-1, -2, -3).multiply(Vector3D.of(1, -2, 3)));
}

test "vector normalize" {
    
    var vector = Vector3D.all(1.0);
    try expect(!vector.is_normalized());

    vector = vector.normalize();
    try expect(vector.is_normalized());

    vector = vector.multiply(Vector3D.of(1, -2, 3));
    try expect(!vector.is_normalized());

    vector = vector.normalize();
    try expect(vector.is_normalized());
}

test "quaternion is normalized" {

    try expect(Quaternion.identity().is_normalized());
    try expect(Quaternion.aroundAxis(Axis.X, 0).is_normalized());
    try expect(Quaternion.aroundAxis(Axis.Y, rad90).is_normalized());
}

test "quaternion multiplied with inverse equals identify" {
    try expectClose(Quaternion.identity().multiply(Quaternion.identity().inverse()), Quaternion.identity());
}

test "quaternion rotation" {

    var vector = Vector3D.of(1, 2, 3);
    
    var rotation = Quaternion.aroundAxis(Axis.X, rad90);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, -3, 2), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, -2, -3), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 3, -2), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3), vector);
    
    rotation = Quaternion.aroundAxis(Axis.Y, rad90);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(3, 2, -1), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-1, 2, -3), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-3, 2, 1), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3), vector);

    rotation = Quaternion.aroundAxis(Axis.Z, rad90);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-2, 1, 3), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-1, -2, 3), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(2, -1, 3), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3), vector);
    
    rotation = Quaternion.aroundAxis(Vector3D.all(1).normalize(), rad90 * 2);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(3, 2, 1), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3), vector);

    rotation = Quaternion.aroundAxis(Vector3D.of(-1, 2, 4).normalize(), math.degreesToRadians(18));
    for(0..10) |_| {
        vector = rotation.rotate(vector);
        vector = vector.rotate(rotation);
    }
    try expectClose( Vector3D.of(1, 2, 3), vector);

}
