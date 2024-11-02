
pub fn Axis(comptime T: type) type {
    
    const Vector3D = @import("vector.zig").Vector3D(T);
    
    return struct {

        pub const x: Vector3D = .{ .x = 1, .y = 0, .z = 0 };
        
        pub const y: Vector3D = .{ .x = 0, .y = 1, .z = 0 };
        
        pub const z: Vector3D = .{ .x = 0, .y = 0, .z = 1 };
    };
}