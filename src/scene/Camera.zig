const algebra = @import("algebra");

const Vector = algebra.Vector3(f32);
const Quaternion = algebra.Quaternion(f32);

const Self = @This();


position: Vector,
rotation: Quaternion,
scale: Vector,

pub fn new() Self {
    return .{
        .position = .zero,
        .rotation = .identity,
        .scale = Vector.all(1.0)
    };
}