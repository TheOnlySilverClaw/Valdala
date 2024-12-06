const algebra = @import("algebra");
const math = @import("std").math;

const Transform = algebra.Transform(f32);
const Vector = algebra.Vector3D(f32);
const Quaternion = algebra.Quaternion(f32);
const Matrix = algebra.Matrix(f32);
const Matrix4x4 = Matrix.Sized(4, 4);
const Matrix1x4 = Matrix.Sized(1, 4);
const Axis = algebra.Axis(f32);


pub const Camera = struct {
    
    transform: Transform,
    fov: f32,

    pub fn new(fieldOfView: f32, width: f32, height: f32, distance: f32) Camera {
        return .{
            .fov = fieldOfView,
            .transform = .{
                .position = Vector.all(0),
                .rotation = Quaternion.identity(),
                .scale = Vector.of(width, height, distance)
            }
        };
    }

    pub fn viewMatrix(self: Camera) Matrix4x4 {
        
        const right = self.transform.pitchAxis();
        const up = self.transform.yawAxis();
        const forward = self.transform.rollAxis();
        
        const position = self.transform.position;
        const translation = Vector {
            .x = -position.dot(right),
            .y = -position.dot(up),
            .z = -position.dot(forward)
        };

        var m = Matrix4x4.zeros();
        m.setColumn(0, right.asMatrix4x1(0).values);
        m.setColumn(1, up.asMatrix4x1(0).values);
        m.setColumn(2, forward.asMatrix4x1(0).values);
        m.setRow(3, translation.asMatrix4x1(1).values);
        return m;
    }

    pub fn projectionMatrix(self: Camera) Matrix4x4 {

        const width = self.transform.scale.x;
        const height = self.transform.scale.y;
        const near = 0.1;
        const far = self.transform.scale.z;
        const inverseRange = 1 / (near - far);
        const aspect = width / height;
        const f = math.tan(math.pi * 0.5 - 0.5 * self.fov);
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

    pub fn asMatrix(self: Camera) Matrix4x4 {
        return self.projectionMatrix().multiply(self.viewMatrix());
    }
};
