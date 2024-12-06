const algebra = @import("algebra");

const Transform = algebra.Transform(f32);
const Vector = algebra.Vector3D(f32);
const Quaternion = algebra.Quaternion(f32);
const Matrix = algebra.Matrix(f32);
const Matrix4x4 = Matrix.Sized(4, 4);
const Matrix1x4 = Matrix.Sized(1, 4);
const Axis = algebra.Axis(f32);


pub const Camera = struct {
    
    transform: Transform,
    focalLength: f32,

    pub fn new(focal: f32, width: f32, height: f32, distance: f32) Camera {
        return .{
            .focalLength = focal,
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
        const offset = self.transform.position.opposite();

        var m = Matrix4x4.zeros();
        m.setRow(0, right.asMatrix4x1(0).values);
        m.setRow(1, up.asMatrix4x1(0).values);
        m.setRow(2, forward.asMatrix4x1(0).values);
        m.setRow(3, offset.asMatrix4x1(1).values);
        return m;
    }

    pub fn projectionMatrix(self: Camera) Matrix4x4 {

        const focalLength = 2.0;
        const width = self.transform.scale.x;
        const height = self.transform.scale.y;
        const ratio = width / height;
        const near = 0.01;
        const far = self.transform.scale.z;
        const divider = 1 / (focalLength * (far - near));
        
        var m = Matrix4x4.zeros();
        m.set(0, 0, 1.0);
        m.set(1, 1, ratio);
        m.set(2, 2, far * divider);
        m.set(3, 2, -far * near * divider);
        m.set(2, 3, 1.0 / focalLength);
        
        return m;
    }

    pub fn asMatrix(self: Camera) Matrix4x4 {
        return self.viewMatrix().multiply(self.projectionMatrix());
    }
};
