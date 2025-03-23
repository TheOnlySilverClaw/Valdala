const algebra = @import("algebra");
const math = @import("std").math;
const std = @import("std");

const Transform = algebra.Transform(f32);
const Vector3 = algebra.vector.Vector3(f32);
const Vector4 = algebra.vector.Vector4(f32);
const Quaternion = algebra.Quaternion(f32);
const Matrix4x4 = algebra.matrix.Matrix4x4(f32);

const Self = @This();

transform: Transform,
fov: f32,

pub fn new(fieldOfView: f32, width: f32, height: f32, distance: f32) Self {
    return .{
        .fov = fieldOfView,
        .transform = .{
            .position = .zeros,
            .rotation = .identity,
            .scale = Vector3.of(width, height, distance),
        },
    };
}

pub fn viewMatrix(self: Self) Matrix4x4 {
    const offset = self.transform.position.flip();
    var translation: Matrix4x4 = .identity;
    translation.set(3, 0, offset.x);
    translation.set(3, 1, offset.y);
    translation.set(3, 2, offset.z);
    const rotation = self.transform.rotation.toMatrix4x4();
    return rotation.multiply(translation);
}

pub fn projectionMatrix(self: Self) Matrix4x4 {
    const fovy_rad = self.fov;
    const scale = self.transform.scale;
    const width = scale.x;
    const height = scale.y;
    const far = scale.z;
    const near = 0.1;
    const aspect = width / height;
    const f = 1.0 / @tan(fovy_rad / 2.0);

    var m: Matrix4x4 = .zeros;
    m.set(0, 0, f / aspect);
    m.set(1, 1, f);
    m.set(2, 2, far / (far - near));
    m.set(2, 3, 1.0);
    m.set(3, 2, -(far * near) / (far - near));
    return m;
}

pub fn asMatrix(self: Self) Matrix4x4 {
    return self.projectionMatrix().multiply(self.viewMatrix());
}
