const Vector3D = @import("vector.zig").Vector3D;

pub const Axis = struct {

    pub const X: Vector3D = .{ .x = 1, .y = 0, .z = 0 };
    
    pub const Y: Vector3D = .{ .x = 0, .y = 1, .z = 0 };
    
    pub const Z: Vector3D = .{ .x = 0, .y = 0, .z = 1 };
};