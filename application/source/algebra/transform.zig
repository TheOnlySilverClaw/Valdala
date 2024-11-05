const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const algebra = @import("algebra.zig");

pub fn Transform(T: type) type {

    const Vector = algebra.Vector3D(T);
    const Quaternion = algebra.Quaternion(T);
    const Axis = algebra.Axis(T);
    const Matrix = algebra.Matrix(T).Sized(4, 4);
    
    return struct {

        const Self = @This();

        position: Vector,
        rotation: Quaternion,
        scale: Vector,

        pub fn origin() Self {
            return .{
                .position = Vector.all(0),
                .rotation = Quaternion.identity(),
                .scale = Vector.all(1)
            };
        }

        pub fn pitchAxis(self: Self) Vector {
            return self.rotation.rotate(Axis.x);
        }

        pub fn rollAxis(self: Self) Vector {
            return self.rotation.rotate(Axis.y);
        }

        pub fn yawAxis(self: Self) Vector {
            return self.rotation.rotate(Axis.z);
        }

        pub fn translate(self: *Self, direction: Vector) void {
            self.position = self.position.add(direction);
        }

        pub fn translateRoll(self: *Self, amount: T) void {
            self.translate(self.rollAxis().scale(amount));
        }

        pub fn translatePitch(self: *Self, amount: T) void {
            self.translate(self.pitchAxis().scale(amount));
        }

        pub fn translateYaw(self: *Self, amount: T) void {
            self.translate(self.yawAxis().scale(amount));
        }

        pub fn rotateRoll(self: *Self, angle: T) void {
            self.rotateAround(self.rollAxis(), angle);
        }

        pub fn rotatePitch(self: *Self, angle: T) void {
            self.rotateAround(self.pitchAxis(), angle);
        }

        pub fn rotateYaw(self: *Self, angle: T) void {
            self.rotateAround(self.yawAxis(), angle);
        }

        pub fn rotateAround(self: *Self, axis: Vector, angle: T) void {
            const rotation = Quaternion.aroundAxis(axis, angle);
            self.position = rotation.rotate(self.position);
            self.rotation = self.rotation.multiply(rotation);
        }

        pub fn scaleFactor(self: *Self, factor: T) void {
            self.scale = self.scale.scale(factor);
        }

        pub fn scaleDimensions(self: *Self, dimensions: Vector) void {
            self.scale = self.scale.multiply(dimensions);
        }

        pub fn matrix() Matrix {
            return undefined;
        }
    };
}
