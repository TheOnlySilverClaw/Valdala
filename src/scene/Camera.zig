const algebra = @import("algebra");
const log = @import("std").log.scoped(.camera);

const Vector = algebra.Vector3;
const Quaternion = algebra.Quaternion;
const Transform = algebra.Transform;
const Matrix = algebra.Matrix;

const Self = @This();


transform: Transform(f32),
near: f32,
far: f32,
fov: f32,
aspect: f32,

pub fn init(fov: f32, aspect: f32, near: f32, far: f32) Self {
    return .{
        .transform = .origin,
        .near = near,
        .far = far,
        .fov = fov,
        .aspect = aspect
    };
}

pub fn toMatrix(self: Self) Matrix(f32, 4, 4) {
    
    const view = self.viewMatrix();
    const projection = self.projectionMatrix();
    return projection.multiply(view);
}

fn viewMatrix(self: Self) Matrix(f32, 4, 4) {

    const scale = Vector(f32).one.divide(self.transform.scale);
    const scale_matrix = Matrix(f32, 4, 4).diagonal(.{ scale.x, scale.y, scale.z, 1 });

    const translation = self.transform.position.inverse();
    var translation_matrix = Matrix(f32, 4, 4).identity;
    translation_matrix.setColumn(3, .{ translation.x, translation.y, translation.z, 1 });

    const rotation_matrix = self.transform.rotation.inverse().toMatrix();
    const matrix = scale_matrix.multiply(rotation_matrix).multiply(translation_matrix);
    
    return matrix;
}

fn projectionMatrix(self: Self) Matrix(f32, 4, 4) {

    const tan_half = @tan(self.fov / 2);
    const aspect = self.aspect;
    const far = self.far;
    const near = self.near;

    var matrix = Matrix(f32, 4, 4).zero;
    matrix.set(0, 0, 1 / (aspect * tan_half));
    matrix.set(1, 1, 1 / tan_half);
    matrix.set(2, 2, far / (near - far));
    matrix.set(2, 3, -1.0);
    matrix.set(3, 2, -(far * near) / (far - near));
    
    return matrix;
}

