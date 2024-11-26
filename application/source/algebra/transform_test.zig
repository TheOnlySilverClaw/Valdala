const std = @import("std");
const math = std.math;
const expect = std.testing.expect;
const expectClose = @import("test.zig").expectClose;

const Axis = @import("axis.zig").Axis(f32);
const Vector = @import("vector.zig").Vector3D(f32);
const Quaternion = @import("quaternion.zig").Quaternion(f32);
const Transform = @import("transform.zig").Transform(f32);

const quarter = math.degreesToRadians(90);
const half = quarter * 2;

test "translate cardinal axes" {
    var t = Transform.origin();

    t.translate(Axis.x.scaleUniform(-0.5));
    try expectClose(Vector.of(-0.5, 0, 0), t.position);

    t.translate(Axis.x.scaleUniform(1.5));
    try expectClose(Vector.of(1, 0, 0), t.position);

    t.translate(Axis.y.scaleUniform(2));
    try expectClose(Vector.of(1, 2, 0), t.position);

    t.translate(Axis.z.scaleUniform(3));
    try expectClose(Vector.of(1, 2, 3), t.position);
}

test "translate original angle axes" {
    var t = Transform.origin();

    t.translateRoll(-0.5);
    try expectClose(Vector.of(0, -0.5, 0), t.position);

    t.translateRoll(1.5);
    try expectClose(Vector.of(0, 1, 0), t.position);

    t.translatePitch(2);
    try expectClose(Vector.of(2, 1, 0), t.position);

    t.translateYaw(3);
    try expectClose(Vector.of(2, 1, 3), t.position);
}

test "rotate original postition" {
    var t = Transform.origin();

    t.rotateAround(Axis.x, 0.5);
    try expectClose(Vector.all(0), t.position);

    t.rotateAround(Axis.x, -0.5);
    try expectClose(Vector.all(0), t.position);

    t.rotateAround(t.pitchAxis(), 1);
    try expectClose(Vector.all(0), t.position);
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

    t.translateRoll(1);
    try expectClose(Vector.of(0, 1, 0), t.position);

    t.rotateYaw(half);
    try expectClose(Vector.of(0, -1, 0), t.position);

    t.rotateYaw(quarter);
    try expectClose(Vector.of(1, 0, 0), t.position);

    t.rotateYaw(math.degreesToRadians(45));
    try expectClose(Vector.of(0.7071, 0.7071, 0), t.position);

    t.rotateYaw(quarter);
    try expectClose(Vector.of(-0.7071, 0.7071, 0), t.position);

    t.rotateYaw(half);
    try expectClose(Vector.of(0.7071, -0.7071, 0), t.position);

    t.rotateYaw(math.degreesToRadians(45));
    try expectClose(Vector.of(1, 0, 0), t.position);
}

test "rotate position around multiple angle axes" {
    var t = Transform.origin();

    t.translateRoll(1);

    t.rotatePitch(half);
    try expectClose(Vector.of(0, -1, 0), t.position);

    t.rotateYaw(quarter);
    try expectClose(Vector.of(-1, 0, 0), t.position);

    t.rotateRoll(quarter);
    try expectClose(Vector.of(-1, 0, 0), t.position);
}

test "apply combined transform to point" {
    const position = Vector.of(1, 2, 3);

    var transform = Transform.origin();
    transform.scaleUniform(2);
    transform.rotateRoll(math.degreesToRadians(90));
    transform.translate(Vector.of(1, 0, -1));

    const applied = transform.apply(position);

    try expectClose(Vector.of(7, 4, -3), applied);
}
