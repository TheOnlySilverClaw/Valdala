const std = @import("std");
const expect = std.testing.expect;
const expectClose = @import("test.zig").expectClose;
const math = std.math;
const algebra = @import("algebra.zig");
const Matrix4x4 = algebra.Matrix(f32).Sized(4, 4);
const Vector = algebra.Vector3D(f32);

test "view projection" {

        var camera = algebra.Transform(f32).origin();
        camera.translateRoll(-1);

        var projection = Matrix4x4.zeros();
        
        const fov: f32 = math.degreesToRadians(120);
        const f: f32 = math.tan((math.pi - fov) / 2.0);
        const width: f32 = 1000;
        const height: f32 = 800;
        const aspect_ratio: f32 = width / height;
        const near: f32 = 0.001;
        const far: f32 = 1000.0;
        const range_inverse = 1.0 / (near - far);

        projection.set(0, 0, f / aspect_ratio);
        projection.set(1, 1, f);
        projection.set(2, 2, far * range_inverse);
        projection.set(2, 3, -1);
        projection.set(3, 3, near * far * range_inverse);

        const cameraMatrix = camera.matrix();
        const viewProjection = projection.multiply(cameraMatrix);

        const top = viewProjection.multiplyResize(1, Vector.of(0, 0.5, 0).asPoint());
        const right = viewProjection.multiplyResize(1, Vector.of(0.5, 0, 0).asPoint());
        const left = viewProjection.multiplyResize(1, Vector.of(-0.5, 0, 0).asPoint());

        // x = 0, y = 1, z = 2, w = 3
        try expectClose(@as(f32, 0), top.values[0]);
        try expectClose(@as(f32, 0), top.values[3]);
        // top y is bigger than the other two
        try expect(top.values[1] > right.values[1]);
        try expect(top.values[1] > left.values[1]);

        try expectClose(@as(f32, 0), right.values[1]);
        try expectClose(@as(f32, 0), right.values[3]);
        // right x is bigger than the other two
        try expect(right.values[0] > top.values[0]);
        try expect(right.values[0] > left.values[0]);
        
        try expectClose(@as(f32, 0), left.values[1]);
        try expectClose(@as(f32, 0), left.values[3]);
        // left x is smaller than the other two
        try expect(left.values[0] < top.values[0]);
        try expect(left.values[0] < right.values[0]);
}
