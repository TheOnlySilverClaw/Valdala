const algebra = @import("algebra");
const log = @import("std").log.scoped(.camera);

const Vector = algebra.Vector3(f32);
const Quaternion = algebra.Quaternion(f32);
const Matrix = algebra.Matrix(f32, 4, 4);

const Self = @This();


position: Vector,
rotation: Quaternion,
zoom: f32,
fov: f32,
aspect: f32,
near: f32,
far: f32,

pub fn new(fov: f32, aspect: f32) Self {
    return .{
        .position = .zero,
        .rotation = .identity,
        .zoom = 1,
        .fov = fov,
        .aspect = aspect,
        .near = 0.1,
        .far = 1000.0
    };
}

pub fn zoomIn(self: *Self, amount: f32) void {
    self.zoom -= amount;
}

pub fn zoomOut(self: *Self, amount: f32) void {
    self.zoom += amount;
}

pub fn moveX(self: *Self, amount: f32) void {
    self.position.x += amount;
}

pub fn moveY(self: *Self, amount: f32) void {
    self.position.y += amount;
}

pub fn movePitch(self: *Self, distance: f32) void {
    self.moveAlongBaseAxis(Vector.Axis.x, distance);
}

pub fn moveRoll(self: *Self, distance: f32) void {
    self.moveAlongBaseAxis(Vector.Axis.y, distance);
}

pub fn moveYaw(self: *Self, distance: f32) void {
    self.moveAlongBaseAxis(Vector.Axis.z, distance);
}

pub fn moveAlong(self: *Self, axis: Vector, distance: f32) void {
    const direction = axis.times(distance);
    self.position = self.position.add(direction);
}

fn moveAlongBaseAxis(self: *Self, base: Vector, distance: f32) void {
    const axis = self.rotation.rotate(base);
    self.moveAlong(axis, distance);
}

pub fn rotateRoll(self: *Self, angle: f32) void {
    self.rotateAroundBaseAxis(Vector.Axis.y, angle);
}

pub fn rotatePitch(self: *Self, angle: f32) void {
    self.rotateAroundBaseAxis(Vector.Axis.x, angle);
}

pub fn rotateYaw(self: *Self, angle: f32) void {
    self.rotateAroundBaseAxis(Vector.Axis.z, angle);
}

pub fn rotateAround(self: *Self, axis: Vector, angle: f32) void {
    const rotation = Quaternion.aroundAxis(axis, angle);
    self.rotation = self.rotation.multiply(rotation);
}

fn rotateAroundBaseAxis(self: *Self, base: Vector, angle: f32) void {
    // if the vector is too small to normalize, the rotation can probably be ignored
    const axis = self.rotation.rotate(base).normalize() catch return;
    self.rotateAround(axis, angle);
}

pub fn toMatrix(self: Self) Matrix {
    
    const view = self.viewMatrix();
    const projection = self.projectionMatrix();
    return projection.multiply(view);
}

fn viewMatrix(self: Self) Matrix {

    const scale = 1 / self.zoom;
    const scale_matrix = Matrix.diagonal(.{ scale, scale, scale, 1 });

    const translation = self.position.inverse();
    var translation_matrix = Matrix.identity;
    translation_matrix.setColumn(3, .{ translation.x, translation.y, translation.z, 1 });

    const rotation_matrix = self.rotation.inverse().toMatrix();
    const matrix = scale_matrix.multiply(rotation_matrix).multiply(translation_matrix);
    
    return matrix;
}

fn projectionMatrix(self: Self) Matrix {

    const fov_half = self.fov / 2;
    const f = 1 / @tan(fov_half);
    const aspect = self.aspect;
    const far = self.far;
    const near = self.near;

    var matrix = Matrix.zero;
    matrix.set(0, 0, f / aspect);
    matrix.set(1, 1, f);
    matrix.set(2, 2, far / (far - near));
    matrix.set(2, 3, 1.0);
    matrix.set(3, 2, -(far * near) / (far - near));
    
    return matrix;
}

