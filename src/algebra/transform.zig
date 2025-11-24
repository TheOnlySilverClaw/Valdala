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
            self.moveAlong(self.pitchAxis(), distance);
        }

        pub fn moveRoll(self: *Self, distance: T) void {
            self.moveAlong(self.rollAxis(), distance);
        }

        pub fn moveYaw(self: *Self, distance: T) void {
            self.moveAlong(self.yawAxis(), distance);
        }

        pub fn pitchAxis(self: Self) Vector {
            return self.rotation.rotate(Vector.axis.x).normalize() catch Vector.axis.x;
        }

        pub fn rollAxis(self: Self) Vector {
            return self.rotation.rotate(Vector.axis.y).normalize() catch Vector.axis.y;
        }

        pub fn yawAxis(self: Self) Vector {
            return self.rotation.rotate(Vector.axis.z).normalize() catch Vector.axis.z;
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

        pub fn scaleUniform(self: *Self, factor: T) void {
            self.scale = self.scale.times(factor);
        }

        pub fn scaleDimensions(self: *Self, dimensions: Vector) void {
            self.scale = self.scale.multiply(dimensions);
        }

        pub fn toMatrix(self: Self) Matrix {
            
            var translation = Matrix.identity;
            translation.setColumn(3, .{ self.position.x, self.position.y, self.position.z, 1 });

            const rotation = self.rotation.toMatrix();

            var scale = Matrix.identity;
            scale.setDiagonal(.{ self.scale.x, self.scale.y, self.scale.z, 1 });

            return translation.multiply(rotation).multiply(scale);
        }
    };
}
