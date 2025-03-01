const std = @import("std");
const math = std.math;
const expect = std.testing.expect;
const expectClose = @import("test_expect.zig").expectClose;

const Axis = @import("axis.zig").Axis(f32);
const Vector = @import("vector.zig").Vector3D(f32);
const Quaternion = @import("quaternion.zig").Quaternion(f32);
const Transform = @import("transform.zig").Transform(f32);

const quarter = math.degreesToRadians(90);
const half = quarter * 2;

fn apply(vector: Vector, transform: Transform) Vector {

    const column = transform.matrix().multiply(vector.asColumnMatrix(1.0));
    return Vector.of(column.values[0], column.values[1], column.values[2]);
}

test "translate cardinal axes" {
    
    var t = Transform.origin();
    const base = t.position;

    t.translate(Axis.x.scaleUniform(-0.5));
    try expectClose(Vector.of(-0.5, 0, 0), apply(base, t));

    t.translate(Axis.x.scaleUniform(1.5));
    try expectClose(Vector.of(1, 0, 0), apply(base, t));

    t.translate(Axis.y.scaleUniform(2));
    try expectClose(Vector.of(1, 2, 0), apply(base, t));

    t.translate(Axis.z.scaleUniform(3));
    try expectClose(Vector.of(1, 2, 3), apply(base, t));
}

test "translate original angle axes" {
    
    var t = Transform.origin();
    const base = t.position;

    t.translateRoll(-0.5);
    try expectClose(Vector.of(0, -0.5, 0), apply(base, t));

    t.translateRoll(1.5);
    try expectClose(Vector.of(0, 1, 0), apply(base, t));

    t.translatePitch(2);
    try expectClose(Vector.of(2, 1, 0), apply(base, t));

    t.translateYaw(3);
    try expectClose(Vector.of(2, 1, 3), apply(base, t));
}

test "rotate original postition" {

    var t = Transform.origin();
    const base = t.position;

    t.rotateAround(Axis.x, half);
    try expectClose(Vector.all(0), apply(base, t));

    t.rotateAround(Axis.x, -half);
    try expectClose(Vector.all(0), apply(base, t));

    t.rotateAround(t.pitchAxis(), 1);
    try expectClose(Vector.all(0), apply(base, t));
}

test "flip angle axes" {

    var t = Transform.origin();

    try expectClose(Axis.x, t.pitchAxis());
    try expectClose(Axis.y, t.rollAxis());
    try expectClose(Axis.z, t.yawAxis());

    t.rotateRoll(half);
    try expectClose(Axis.x.opposite(), t.pitchAxis());
    try expectClose(Axis.y, t.rollAxis());
    try expectClose(Axis.z.opposite(), t.yawAxis());

    t.rotateRoll(half);
    try expectClose(Axis.x, t.pitchAxis());
    try expectClose(Axis.y, t.rollAxis());
    try expectClose(Axis.z, t.yawAxis());

    t.rotatePitch(half);
    try expectClose(Axis.x, t.pitchAxis());
    try expectClose(Axis.y.opposite(), t.rollAxis());
    try expectClose(Axis.z.opposite(), t.yawAxis());

    t.rotatePitch(-half);

    t.rotateYaw(half);
    try expectClose(Axis.x.opposite(), t.pitchAxis());
    try expectClose(Axis.y.opposite(), t.rollAxis());
    try expectClose(Axis.z, t.yawAxis());

    t.rotateRoll(half);
    try expectClose(Axis.x, t.pitchAxis());
    try expectClose(Axis.y.opposite(), t.rollAxis());
    try expectClose(Axis.z.opposite(), t.yawAxis());
}

test "rotate position around one angle axis" {

    var t = Transform.origin();
    const base = Vector.of(0, 1, 0);

    t.rotateYaw(half);
    try expectClose(Vector.of(0, -1, 0), apply(base, t));

    t.rotateYaw(quarter);
    try expectClose(Vector.of(1, 0, 0), apply(base, t));

    t.rotateYaw(math.degreesToRadians(45));
    try expectClose(Vector.of(0.7071, 0.7071, 0), apply(base, t));

    t.rotateYaw(quarter);
    try expectClose(Vector.of(-0.7071, 0.7071, 0), apply(base, t));

    t.rotateYaw(half);
    try expectClose(Vector.of(0.7071, -0.7071, 0), apply(base, t));

    t.rotateYaw(math.degreesToRadians(45));
    try expectClose(Vector.of(1, 0, 0), apply(base, t));
}

test "rotate position around multiple angle axes" {

    var t = Transform.origin();
    const base = Vector.of(1, 2, 3);

    t.rotatePitch(half);
    try expectClose(Vector.of(1, -2, -3), apply(base, t));

    t.rotateYaw(quarter);
    try expectClose(Vector.of(2, 1, -3), apply(base, t));

    t.rotateRoll(half);
    try expectClose(Vector.of(2, -1, 3), apply(base, t));
}

test "apply combined transform to point" {

    const position = Vector.of(1, 2, 3);

    var transform = Transform.origin();
    transform.scaleUniform(2);
    transform.rotateRoll(math.degreesToRadians(90));
    transform.translate(Vector.of(3, 0, -5));

    const applied = apply(position, transform);

    try expectClose(Vector.of(9, 4, -7), applied);
}
