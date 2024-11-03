const std = @import("std");
const math = std.math;
const algebra = @import("algebra.zig");
const expect = std.testing.expect;

const Vector3D = algebra.Vector3D(f32);
const Quaternion = algebra.Quaternion(f32);
const Axis = algebra.Axis(f32);

test {
    _ = @import("matrix.zig");
}

const rad90: f32 = math.degreesToRadians(90.0);

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
    try expect(!vector.isNormalized());

    vector = vector.normalize();
    try expect(vector.isNormalized());

    vector = vector.multiply(Vector3D.of(1, -2, 3));
    try expect(!vector.isNormalized());

    vector = vector.normalize();
    try expect(vector.isNormalized());
}

test "quaternion is normalized" {

    try expect(Quaternion.identity().isNormalized());
    try expect(Quaternion.aroundAxis(Axis.x, 0).isNormalized());
    try expect(Quaternion.aroundAxis(Axis.y, rad90).isNormalized());
}

test "quaternion multiplied with inverse equals identify" {
    try expectClose(Quaternion.identity().multiply(Quaternion.identity().inverse()), Quaternion.identity());
}

test "quaternion rotation" {

    var vector = Vector3D.of(1, 2, 3);
    
    var rotation = Quaternion.aroundAxis(Axis.x, rad90);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, -3, 2), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, -2, -3), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 3, -2), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3), vector);
    
    rotation = Quaternion.aroundAxis(Axis.y, rad90);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(3, 2, -1), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-1, 2, -3), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-3, 2, 1), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3), vector);

    rotation = Quaternion.aroundAxis(Axis.z, rad90);
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
    for(0..20) |_| {
        vector = rotation.rotate(vector);
    }
    try expectClose( Vector3D.of(1, 2, 3), vector);

}