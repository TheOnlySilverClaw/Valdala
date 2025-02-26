const std = @import("std");
const math = std.math;
const Vector3D = @import("vector.zig").Vector3D(f32);
const Axis = @import("axis.zig").Axis(f32);
const Quaternion = @import("quaternion.zig").Quaternion(f32);

const expectClose = @import("test_expect.zig").expectClose;
const expect = std.testing.expect;

pub const rad90: f32 = math.degreesToRadians(90.0);

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
    try expectClose(Vector3D.of(1, -3, 2).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, -2, -3).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 3, -2).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3).normalize(), vector);
    
    rotation = Quaternion.aroundAxis(Axis.y, rad90);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(3, 2, -1).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-1, 2, -3).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-3, 2, 1).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3).normalize(), vector);

    rotation = Quaternion.aroundAxis(Axis.z, rad90);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-2, 1, 3).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(-1, -2, 3).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(2, -1, 3).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3).normalize(), vector);
    
    rotation = Quaternion.aroundAxis(Vector3D.all(1).normalize(), rad90 * 2);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(3, 2, 1).normalize(), vector);
    vector = rotation.rotate(vector);
    try expectClose(Vector3D.of(1, 2, 3).normalize(), vector);

    rotation = Quaternion.aroundAxis(Vector3D.of(-1, 2, 4).normalize(), math.degreesToRadians(18));
    for(0..20) |_| {
        vector = rotation.rotate(vector);
    }
    try expectClose( Vector3D.of(1, 2, 3).normalize(), vector);
}

test "matrix" {

    const angle = math.degreesToRadians(60);

    const q = Quaternion.aroundAxis(Axis.x, angle);
    const m = q.matrix();

    try expectClose(@as(f32, math.cos(angle)), m.get(1, 1));
    try expectClose(@as(f32, -math.sin(angle)), m.get(2, 1));
    try expectClose(@as(f32, math.sin(angle)), m.get(1, 2));
    try expectClose(@as(f32, math.cos(angle)), m.get(2, 2));
    
    try expectClose(@as(f32, 1), m.get(0, 0));
    try expectClose(@as(f32, 1), m.get(3, 3));
    try expectClose(@as(f32, 0), m.get(0, 3));
    try expectClose(@as(f32, 0), m.get(1, 3));
}

test "eulerAngles" {

    var q = Quaternion.identity();
    
    try expectClose(Vector3D.all(0.0), q.eulerAngles());

    q = Quaternion.aroundAxis(Axis.x, 0.5);
    try expectClose(Vector3D.of(0.5, 0.0, 0.0), q.eulerAngles());

    q = Quaternion.aroundAxis(Axis.y, 0.5);
    try expectClose(Vector3D.of(0.0, 0.5, 0.0), q.eulerAngles());

    q = Quaternion.aroundAxis(Axis.z, 0.5);
    try expectClose(Vector3D.of(0.0, 0.0, 0.5), q.eulerAngles());
}