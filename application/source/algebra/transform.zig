const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const algebra = @import("module.zig");

pub fn Transform(T: type) type {
    const Vector3 = algebra.vector.Vector3(T);
    const Axis = algebra.Axis(T);
    const Quaternion = algebra.Quaternion(T);
    const Matrix4x4 = algebra.matrix.Matrix4x4(T);

    return struct {
        const Self = @This();

        position: Vector3,
        rotation: Quaternion,
        scale: Vector3,

        pub fn origin() Self {
            return .{
                .position = .zeros,
                .rotation = .identity,
                .scale = .all(1),
            };
        }

        pub fn pitchAxis(self: *Self) Vector3 {
            return self.rotation.rotateVector3(Axis.x);
        }

        pub fn yawAxis(self: *Self) Vector3 {
            return self.rotation.rotateVector3(Axis.y);
        }

        pub fn rollAxis(self: *Self) Vector3 {
            return self.rotation.rotateVector3(Axis.z);
        }

        pub fn translateWorldframe(self: *Self, direction: Vector3) void {
            self.position = self.position.add(direction);
        }

        pub fn translateLocalframe(self: *Self, direction: Vector3) void {
            const local_rotation = self.rotation.rotateVector3(direction);
            self.position = self.position.add(local_rotation);
        }

        pub fn translateWorldX(self: *Self, amount: T) void {
            self.position = Vector3.of(self.position.x + amount, self.position.y, self.position.z);
        }

        pub fn translateWorldY(self: *Self, amount: T) void {
            self.position = Vector3.of(self.position.x, self.position.y + amount, self.position.z);
        }

        pub fn translateWorldZ(self: *Self, amount: T) void {
            self.position = Vector3.of(self.position.x, self.position.y, self.position.z + amount);
        }

        pub fn translatePitch(self: *Self, amount: T) void {
            var localx = pitchAxis(self);
            localx = localx.scalarMultiply(amount);
            self.position = self.position.add(localx);
        }

        pub fn translateYaw(self: *Self, amount: T) void {
            var localx = yawAxis(self);
            localx = localx.scalarMultiply(amount);
            self.position = self.position.add(localx);
        }

        pub fn translateRoll(self: *Self, amount: T) void {
            var localx = rollAxis(self);
            localx = localx.scalarMultiply(amount);
            self.position = self.position.add(localx);
        }

        pub fn rotatePitch(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Axis.x, angle);
            self.rotation = self.rotation.multiply(rotation);
        }

        pub fn rotateYaw(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Axis.y, angle);
            self.rotation = self.rotation.multiply(rotation);
        }

        pub fn rotateRoll(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Axis.z, angle);
            self.rotation = self.rotation.multiply(rotation);
        }

        pub fn rotateWorldX(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Axis.x, angle);
            self.rotation = rotation.multiply(self.rotation);
        }

        pub fn rotateWorldY(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Axis.y, angle);
            self.rotation = rotation.multiply(self.rotation);
        }

        pub fn rotateWorldZ(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Axis.z, angle);
            self.rotation = rotation.multiply(self.rotation);
        }

        pub fn rotateWorld(self: *Self, axis: Vector3, angle: T) void {
            const rotation = Quaternion.aroundAxis(axis, angle);
            self.rotation = rotation.multiply(self.rotation);
        }

        pub fn rotateLocal(self: *Self, axis: Vector3, angle: T) void {
            const rotation = Quaternion.aroundAxis(axis, angle);
            self.rotation = self.rotation.multiply(rotation);
        }

        pub fn scaleUniform(self: *Self, factor: T) void {
            self.scale = self.scale.scalarMultiply(factor);
        }

        pub fn scaleBy(self: *Self, dimensions: Vector3) void {
            self.scale = self.scale.elementwiseMultiply(dimensions);
        }

        pub fn toMatrix4x4(self: Self) Matrix4x4 {
            var translation: Matrix4x4 = .identity;
            translation.set(3,0,self.position.x);
            translation.set(3,1,self.position.y);
            translation.set(3,2,self.position.z);

            const rotation = self.rotation.toMatrix4x4();

            var scale: Matrix4x4 = .zeros;
            scale.set(0, 0, self.scale.x);
            scale.set(1, 1, self.scale.y);
            scale.set(2, 2, self.scale.z);
            scale.set(3, 3, 1);
            // T * R * S
            return translation.multiply(scale.multiply(rotation));
        }
    };
}
