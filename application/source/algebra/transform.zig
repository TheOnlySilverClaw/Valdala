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

        pub fn translateX(self: *Self, amount: T) void {
            self.position = Vector.of(self.position.x + amount, self.position.y, self.position.z);
        }

        pub fn translateY(self: *Self, amount: T) void {
            self.position = Vector.of(self.position.x, self.position.y + amount, self.position.z);
        }

        pub fn translateZ(self: *Self, amount: T) void {
            self.position = Vector.of(self.position.x, self.position.y, self.position.z + amount);
        }

        pub fn translateRoll(self: *Self, amount: T) void {
            self.translate(self.rollAxis().scaleUniform(amount));
        }

        pub fn translatePitch(self: *Self, amount: T) void {
            self.translate(self.pitchAxis().scaleUniform(amount));
        }

        pub fn translateYaw(self: *Self, amount: T) void {
            self.translate(self.yawAxis().scaleUniform(amount));
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

        pub fn scaleUniform(self: *Self, factor: T) void {
            self.scale = self.scale.scaleUniform(factor);
        }

        pub fn scaleBy(self: *Self, dimensions: Vector) void {
            self.scale = self.scale.multiply(dimensions);
        }

        pub fn matrix(self: Self) Matrix {
            _ = self;
            return Matrix.identity();
        }

        // mainly for debugging
        pub fn apply(self: Self, point: Vector) Vector {

            const scaled = point.scaleBy(self.scale);
            const rotated = self.rotation.rotate(scaled);
            const translated = rotated.add(self.position);
            return translated;
        }
    };
}
