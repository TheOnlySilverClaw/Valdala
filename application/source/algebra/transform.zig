const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const algebra = @import("module.zig");

pub fn Transform(T: type) type {
    const Vector3 = algebra.vector.Vector3(T);
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
                .scale = .{ .x = 1, .y = 1, .z = 1 },
            };
        }

        pub fn localXAxis(self: *const Self) Vector3 {
            return self.rotation.rotateVector3(&Vector3.unit_x);
        }

        pub fn localYAxis(self: *const Self) Vector3 {
            return self.rotation.rotateVector3(&Vector3.unit_y);
        }

        pub fn localZAxis(self: *const Self) Vector3 {
            return self.rotation.rotateVector3(&Vector3.unit_z);
        }

        pub fn translateAlongWorldframe(self: *Self, direction: Vector3) void {
            self.position = self.position.add(direction);
        }

        pub fn translateAlongLocalframe(self: *Self, direction: Vector3) void {
            const local_rotation = self.rotation.rotateVector3(&direction);
            self.position = self.position.add(local_rotation);
        }

        pub fn translateAlongWorldX(self: *Self, amount: T) void {
            self.position = Vector3.of(self.position.x + amount, self.position.y, self.position.z);
        }

        pub fn translateAlongWorldY(self: *Self, amount: T) void {
            self.position = Vector3.of(self.position.x, self.position.y + amount, self.position.z);
        }

        pub fn translateAlongWorldZ(self: *Self, amount: T) void {
            self.position = Vector3.of(self.position.x, self.position.y, self.position.z + amount);
        }

        pub fn translateAlongLocalX(self: *Self, amount: T) void {
            var localx = localXAxis(self);
            localx = localx.scalarMultiply(amount);
            self.position = self.position.add(localx);
        }

        pub fn translateAlongLocalY(self: *Self, amount: T) void {
            var localx = localYAxis(self);
            localx = localx.scalarMultiply(amount);
            self.position = self.position.add(localx);
        }

        pub fn translateAlongLocalZ(self: *Self, amount: T) void {
            var localx = localZAxis(self);
            localx = localx.scalarMultiply(amount);
            self.position = self.position.add(localx);
        }

        pub fn rotateAroundLocalX(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Vector3.unit_x, angle);
            self.rotation = self.rotation.multiply(&rotation);
        }

        pub fn rotateAroundLocalY(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Vector3.unit_y, angle);
            self.rotation = self.rotation.multiply(&rotation);
        }

        pub fn rotateAroundLocalZ(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Vector3.unit_z, angle);
            self.rotation = self.rotation.multiply(&rotation);
        }

        pub fn rotateAroundWorldX(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Vector3.unit_x, angle);
            self.rotation = rotation.multiply(&self.rotation);
        }

        pub fn rotateAroundWorldY(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Vector3.unit_y, angle);
            self.rotation = rotation.multiply(&self.rotation);
        }

        pub fn rotateAroundWorldZ(self: *Self, angle: T) void {
            const rotation = Quaternion.aroundAxis(Vector3.unit_z, angle);
            self.rotation = rotation.multiply(&self.rotation);
        }

        pub fn rotateAroundWorld(self: *Self, axis: Vector3, angle: T) void {
            const rotation = Quaternion.aroundAxis(axis, angle);
            self.rotation = rotation.multiply(&self.rotation);
        }

        pub fn rotateAroundLocal(self: *Self, axis: Vector3, angle: T) void {
            const rotation = Quaternion.aroundAxis(axis, angle);
            self.rotation = self.rotation.multiply(&rotation);
        }

        pub fn scaleUniform(self: *Self, factor: T) void {
            self.scale = self.scale.scalarMultiply(factor);
        }

        pub fn scaleBy(self: *Self, dimensions: Vector3) void {
            self.scale = self.scale.elementwiseMultiply(dimensions);
        }

        pub fn toMatrix4x4(self: Self) Matrix4x4 {
            var translation: Matrix4x4 = .identity;
            translation.z.x = self.position.x;
            translation.z.y = self.position.y;
            translation.z.z = self.position.z;

            const rotation = self.rotation.toMatrix4x4();

            var scale: Matrix4x4 = .zeros;
            scale.x.x  = self.scale.x;
            scale.y.y  = self.scale.y;
            scale.z.z  = self.scale.z;
            scale.w.w  = 1;
            // T * R * S
            return translation.multiply(scale.multiply(rotation));
        }
    };
}
