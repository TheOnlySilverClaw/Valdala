const algebra = @import("algebra");
const math = @import("std").math;

const Transform = algebra.Transform(f32);
const Vector = algebra.Vector3D(f32);
const Quaternion = algebra.Quaternion(f32);
const Matrix = algebra.Matrix(f32);
const Matrix4x4 = Matrix.Sized(4, 4);
const Matrix1x4 = Matrix.Sized(1, 4);
const Axis = algebra.Axis(f32);

const Self = @This();

transform: Transform,
fov: f32,

pub fn new(fieldOfView: f32, width: f32, height: f32, distance: f32) Self {
    return .{
        .fov = fieldOfView,
        .transform = .{
            .position = Vector.all(0),
            .rotation = Quaternion.identity(),
            .scale = Vector.of(width, height, distance)
        }
    };
}

pub fn viewMatrix(self: Self) Matrix4x4 {
    
    const right = self.transform.pitchAxis();
    const up = self.transform.yawAxis();
    const forward = self.transform.rollAxis();
    
    const position = self.transform.position;

    var m = Matrix4x4.zeros();

    m.set(0, 0, right.x);
    m.set(0, 1, right.y);
    m.set(0, 2, right.z);

    m.set(1, 0, up.x);
    m.set(1, 1, up.y);
    m.set(1, 2, up.z);

    m.set(2, 0, forward.x);
    m.set(2, 1, forward.y);
    m.set(2, 2, forward.z);

    m.set(0, 3, -position.dot(right));
    m.set(1, 3, -position.dot(up));
    m.set(2, 3, -position.dot(forward));
    m.set(3, 3, 1);

    return m;
}

// see https://github.com/g-truc/glm/blob/master/glm/ext/matrix_clip_space.inl perspectiveRH_ZO
pub fn projectionMatrix(self: Self) Matrix4x4 {

    const scale = self.transform.scale;
    const width = scale.x;
    const height = scale.y;
    const far = scale.z;
    const near = 0.1;
    const aspect = width / height;
    const tan_half_fov = math.tan(self.fov / 2.0);
    
    var m = Matrix4x4.zeros();

    m.set(0, 0, 1 / (aspect * tan_half_fov));
    m.set(1, 1, 1 / tan_half_fov);
    m.set(2, 2, far / (near - far));
    m.set(2, 3, -1.0);
    m.set(3, 2, -(far * near) / (far - near));
    
    return m;
}

pub fn asMatrix(self: Self) Matrix4x4 {
    return self.projectionMatrix().multiply(self.viewMatrix());
}
