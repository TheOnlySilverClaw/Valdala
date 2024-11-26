const std = @import("std");
const math = std.math;
const algebra = @import("algebra.zig");
const Matrix4x4 = algebra.Matrix(f32).Sized(4, 4);

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

        const vertex = algebra.Vector3D(f32).of(0.5, 0.5, 0);

        const projected = viewProjection.multiplyResize(1, vertex.toMatrix4x1(1));

        projected.print();
}