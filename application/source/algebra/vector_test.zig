const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const Vector3D = @import("vector.zig").Vector3D(f32);
const expect = std.testing.expect;
const expectClose = @import("test_expect.zig").expectClose;

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

test "as column matrix" {

    const vector = Vector3D.of(0, 1, 2);
    const matrix = vector.asColumnMatrix(3);
    
    try expectClose(@as(f32, 0), matrix.get(0, 0));
    try expectClose(@as(f32, 1), matrix.get(0, 1));
    try expectClose(@as(f32, 2), matrix.get(0, 2));
    try expectClose(@as(f32, 3), matrix.get(0, 3));
}

test "as row matrix" {

    const vector = Vector3D.of(0, 1, 2);
    const matrix = vector.asRowMatrix(3);
    
    try expectClose(@as(f32, 0), matrix.get(0, 0));
    try expectClose(@as(f32, 1), matrix.get(1, 0));
    try expectClose(@as(f32, 2), matrix.get(2, 0));
    try expectClose(@as(f32, 3), matrix.get(3, 0));
}