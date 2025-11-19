pub fn Transform(T: type) type {
    
    const Vector = @import("vector3.zig").Vector3(T);
    const Quaternion = @import("quaternion.zig").Quaternion(T);
    const Matrix = @import("matrix.zig").Matrix(T, 4, 4);

    return struct {

        const Self = @This();

        pub const origin = Self {
            .position = .zero,
            .rotation = .identity,
            .scale = .one
        };

        position: Vector,
        rotation: Quaternion,
        scale: Vector,

        pub fn moveX(self: *Self, amount: T) void {
            self.position.x += amount;
        }

        pub fn moveY(self: *Self, amount: T) void {
            self.position.y += amount;
        }

        pub fn moveZ(self: *Self, amount: T) void {
            self.position.z += amount;
        }

        pub fn movePitch(self: *Self, distance: T) void {
            self.moveLocal(Vector.axis.x, distance);
        }

        pub fn moveRoll(self: *Self, distance: T) void {
            self.moveLocal(Vector.axis.y, distance);
        }

        pub fn moveYaw(self: *Self, distance: T) void {
            self.moveLocal(Vector.axis.z, distance);
        }

        fn moveLocal(self: *Self, base: Vector, distance: T) void {
            const axis = self.rotation.rotate(base);
            self.moveAlong(axis, distance);
        }

        pub fn moveAlong(self: *Self, axis: Vector, distance: T) void {
            const direction = axis.times(distance);
            self.position = self.position.add(direction);
        }

        pub fn rotateRoll(self: *Self, angle: T) void {
            self.rotateLocal(Vector.axis.y, angle);
        }

        pub fn rotatePitch(self: *Self, angle: T) void {
            self.rotateLocal(Vector.axis.x, angle);
        }

        pub fn rotateYaw(self: *Self, angle: T) void {
            self.rotateLocal(Vector.axis.z, angle);
        }

        pub fn rotateAround(self: *Self, axis: Vector, angle: T) void {
            const rotation = Quaternion.aroundAxis(axis, angle);
            self.rotation = self.rotation.multiply(rotation);
        }

        fn rotateLocal(self: *Self, base: Vector, angle: T) void {
            // if the vector is too small to normalize, the rotation can probably be ignored
            const axis = self.rotation.rotate(base).normalize() catch return;
            self.rotateAround(axis, angle);
        }

        pub fn toMatrix(self: Self) Matrix {
            _ = self;
            return undefined;
        }
    };
}
