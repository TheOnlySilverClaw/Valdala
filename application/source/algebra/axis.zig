pub fn Axis(comptime T: type) type {
    
    const Vector3 = @import("vector.zig").Vector3(T);
    
    return struct {

        pub const x: Vector3 = .{ .x = 1, .y = 0, .z = 0 };
        
        pub const y: Vector3 = .{ .x = 0, .y = 1, .z = 0 };
        
        pub const z: Vector3 = .{ .x = 0, .y = 0, .z = 1 };
    };
}
