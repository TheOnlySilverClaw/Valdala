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

pub fn toMatrix(self: Self) Matrix {

    // const forward = self.rotation.apply(Vector.Axis.y);
    // const right = self.rotation.apply(Vector.Axis.x);
    // const up = self.rotation.apply(Vector.Axis.z);

    var matrix = Matrix.zero();
    // matrix.setRow(0, .{ forward.x, forward.y, forward.z, 0 });
    // matrix.setRow(1, .{ right.x, right.y, right.z, 0 });
    // matrix.setRow(2, .{ up.x, up.y, up.z, 0 });

    const zoom_factor = 1 / self.zoom;
    const offset = self.position.inverse();
    matrix.setDiagonal(.{ zoom_factor, zoom_factor, zoom_factor, 1 });
    matrix.setColumn(3, .{ offset.x, offset.y, offset.z, 1 });
    return matrix;
}