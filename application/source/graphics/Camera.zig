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
    const up = Axis.z;
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

pub fn projectionMatrix(self: Self) Matrix4x4 {

    const width = self.transform.scale.x;
    const height = self.transform.scale.y;
    const near = 0.1;
    const far = self.transform.scale.z;
    const inverseRange = 1 / (near - far);
    const aspect = width / height;
    const f = math.tan((math.pi - self.fov) / 2.0);
    var m = Matrix4x4.zeros();

    m.values[0] = f / aspect;
    m.values[1] = 0;
    m.values[2] = 0;
    m.values[3] = 0;
    
    m.values[4] = 0;
    m.values[5] = f;
    m.values[6] = 0;
    m.values[7] = 0;

    m.values[8] = 0;
    m.values[9] = 0;
    m.values[10] = far * inverseRange;
    m.values[11] = -1;
    
    m.values[12] = 0;
    m.values[13] = 0;
    m.values[14] = far * near * inverseRange;
    m.values[15] = 0;
    
    return m;
}

pub fn asMatrix(self: Self) Matrix4x4 {
    return self.viewMatrix().multiply(self.projectionMatrix());
}
