const std = @import("std");
const math = std.math;
const algebra = @import("algebra.zig");
const expect = std.testing.expect;

const Vector3D = algebra.Vector3D(f32);
const Quaternion = algebra.Quaternion(f32);
const Axis = algebra.Axis(f32);

test {
    _ = @import("matrix_test.zig");
    _ = @import("quaternion_test.zig");
    _ = @import("transform_test.zig");
    _ = @import("vector_test.zig");
    _ = @import("view_projection_test.zig");
}


pub fn expectClose(expected: anytype, actual: anytype) !void {
    
    const T = @TypeOf(expected);
    return switch (T) {
        f32 => try std.testing.expectApproxEqAbs(expected, actual, 1e-5),
        Vector3D => {
            try expectClose(expected.x, actual.x);
            try expectClose(expected.y, actual.y);
            try expectClose(expected.z, actual.z);
        },
        Quaternion => {
            try expectClose(expected.x, actual.x);
            try expectClose(expected.y, actual.y);
            try expectClose(expected.z, actual.z);
            try expectClose(expected.w, actual.w);
        },
        else => @compileError("unsupported type")
    };
}

