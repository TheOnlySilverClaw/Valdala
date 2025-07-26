const algebra = @import("algebra");

const Vector = algebra.Vector3(f32);
const Quaternion = algebra.Quaternion(f32);
const Matrix = algebra.Matrix(f32, 4, 4);

const Self = @This();


position: Vector,
rotation: Quaternion,
zoom: f32,

pub fn new() Self {
    return .{
        .position = .zero,
        .rotation = .identity,
        .zoom = 1
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

pub fn movePitch(self: *Self, amount: f32) void {
    const pitch_axis = self.rotation.apply(Vector.Axis.x);
    const move_vector = pitch_axis.times(amount);
    self.position = self.position.add(move_vector);
}

pub fn moveYaw(self: *Self, amount: f32) void {
    const yaw_axis = self.rotation.apply(Vector.Axis.y);
    const move_vector = yaw_axis.times(amount);
    self.position = self.position.add(move_vector);
}

pub fn rotateRoll(self: *Self, angle: f32) void {
    const roll_axis = self.rotation.apply(Vector.Axis.z);
    const axis_rotation = Quaternion.aroundAxis(roll_axis, angle);
    self.rotation = self.rotation.multiply(axis_rotation);
}

pub fn toMatrix(self: Self) Matrix {

    // const forward = self.rotation.apply(Vector.Axis.y);
    // const right = self.rotation.apply(Vector.Axis.x);
    // const up = self.rotation.apply(Vector.Axis.z);

    // var model_matrix = Matrix.zero();
    // matrix.setRow(0, .{ forward.x, forward.y, forward.z, 0 });
    // matrix.setRow(1, .{ right.x, right.y, right.z, 0 });
    // matrix.setRow(2, .{ up.x, up.y, up.z, 0 });

    const scale = 1 / self.zoom;
    const scale_matrix = Matrix.diagonal(.{ scale, scale, scale, 1 });

    const translation = self.position.inverse();
    var translation_matrix = Matrix.identity;
    translation_matrix.setColumn(3, .{ translation.x, translation.y, translation.z, 1 });

    const rotation_matrix = self.rotation.inverse().toMatrix();
    const model_matrix = scale_matrix.multiply(rotation_matrix).multiply(translation_matrix);
    
    return model_matrix;
}