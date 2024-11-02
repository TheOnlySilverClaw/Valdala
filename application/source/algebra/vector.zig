const std = @import("std");
const math = std.math;
const Quaternion = @import("quaternion.zig").Quaternion;
const assert = std.debug.assert;


pub const Vector3D = struct {

    x: f32,
    y: f32,
    z: f32,

    pub fn of(x: f32, y: f32, z: f32) Vector3D {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn all(value: f32) Vector3D {
        return .{ .x = value, .y = value, .z = value };
    }

    pub fn dot(self: Vector3D, other: Vector3D) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn cross(self: Vector3D, other: Vector3D) Vector3D {
        return .{
            .x = self.y * other.z - other.y * self.z,
            .y = self.z * other.x - other.z * self.x,
            .z = self.x * other.y - other.x * self.y,
        };    
    }

    pub fn isNormalized(self: Vector3D) bool {
        return @abs(self.lengthSquared() - 1.0) <= 1e-4;
    }

    pub fn rotate(self: Vector3D, rotation: Quaternion) Vector3D {
        return rotation.rotate(self);
    }

    pub fn normalize(self: Vector3D) Vector3D {

        const reciprocal = 1.0 / self.length();
        assert(reciprocal > 0.0);
        return self.multiply(Vector3D.all(reciprocal));
    }

    pub fn add(self: Vector3D, other: Vector3D) Vector3D {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z
        };
    }

    pub fn multiply(self: Vector3D, other: Vector3D) Vector3D {
        return .{
            .x = self.x * other.x,
            .y = self.y * other.y,
            .z = self.z * other.z
        };
    }

    pub fn scale(self: Vector3D, value: f32) Vector3D {
        return .{
            .x = self.x * value,
            .y = self.y * value,
            .z = self.z * value
        };
    }

    pub fn length(self: Vector3D) f32 {
        return math.sqrt(self.lengthSquared());
    }

    fn lengthSquared(self: Vector3D) f32 {
        return self.dot(self);
    }
};