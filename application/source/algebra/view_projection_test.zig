const std = @import("std");
const expect = std.testing.expect;
const expectClose = @import("test.zig").expectClose;
const math = std.math;
const algebra = @import("algebra.zig");
const Matrix4x4 = algebra.Matrix(f32).Sized(4, 4);
const Vector = algebra.Vector3D(f32);
const Camera = @import("camera.zig").Camera;


test "view projection" {

        var camera = Camera.new(2.0,1000, 800, 100.0);
        camera.transform.translateZ(-3);
        camera.transform.rotatePitch(-math.degreesToRadians(90));

        const viewProjection = camera.asMatrix();
        std.debug.print(" --- \n", .{});
        viewProjection.print();

        const top = toDeviceCoordinates(viewProjection, Vector.of(0, 0.5, 0));
        const right = toDeviceCoordinates(viewProjection,Vector.of(0.5, 0, 0));
        const left = toDeviceCoordinates(viewProjection, Vector.of(-0.5, 0, 0));

        top.print();
        std.debug.print(" --- \n", .{});
        right.print();
        std.debug.print(" --- \n", .{});
        left.print();

        // // x = 0, y = 1, z = 2, w = 3
        // try expectClose(@as(f32, 0), top.x);
        // try expectClose(@as(f32, 0), top.w);
        // // top y is bigger than the other two
        // try expect(top.values[1] > right.values[1]);
        // try expect(top.values[1] > left.values[1]);

        // try expectClose(@as(f32, 0), right.values[1]);
        // try expectClose(@as(f32, 0), right.values[3]);
        // // right x is bigger than the other two
        // try expect(right.values[0] > top.values[0]);
        // try expect(right.values[0] > left.values[0]);

        // try expectClose(@as(f32, 0), left.values[1]);
        // try expectClose(@as(f32, 0), left.values[3]);
        // // left x is smaller than the other two
        // try expect(left.values[0] < top.values[0]);
        // try expect(left.values[0] < right.values[0]);
}

fn toDeviceCoordinates(viewProjection: Matrix4x4, vector: Vector) Vector {

        const point = vector.asPoint();
        const projected = viewProjection.multiplyResize(1, point);
        const w = projected.values[3];
        const normalized = Vector{
                .x = projected.values[0] / w,
                .y = projected.values[1] / w,
                .z = projected.values[2] / w,
        };
        return normalized;
}