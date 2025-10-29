const algebra = @import("algebra");

window: Window,
movement: Movement,

pub fn new() @This() {
    return .{
        .window = .{
            .close = false,
            .resize = .none
        },
        .movement = .{
            .direction = .zero,
            .rotation = .{
                .pitch = 0,
                .yaw = 0,
            }
        }
    };
}

pub const Movement = struct {
    direction: algebra.Vector3(f32),
    rotation: struct {
        pitch: f32,
        yaw: f32,
        // This is just an expanded matrix multiplication because I couldn't figure out how to multiply the matrix by a vector
        pub fn project(self: @This(), vector: algebra.Vector3(f32)) algebra.Vector3(f32) {
            const cosPitch = @cos(self.pitch);
            const sinPitch = @sin(self.pitch);
            const cosYaw = @cos(self.yaw);
            const sinYaw = @sin(self.yaw);

            return .of(
                vector.x * sinYaw * sinPitch + vector.y * cosYaw - vector.z * sinYaw * cosPitch,
                vector.x * cosYaw * sinPitch - vector.y * sinYaw - vector.z * cosYaw * cosPitch,
                vector.x * cosPitch + vector.z * sinPitch,
            );
        }
    }
};

pub const Window = struct {
    close: bool,
    resize: union(enum) {
        none,
        size: struct {
            width: u32,
            height: u32
        }
    },
};
