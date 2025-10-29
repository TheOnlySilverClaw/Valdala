const algebra = @import("algebra");
const math = @import("std").math;

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

        pub fn project(self: @This(), vector: algebra.Vector3(f32)) algebra.Vector3(f32) {
            // Adjust to be anticlockwise from the origin
            const adjusted_pitch = math.pi / 2.0 - self.pitch;
            const adjusted_yaw = -self.yaw;

            const cos_pitch = @cos(adjusted_pitch);
            const sin_pitch = @sin(adjusted_pitch);
            const cos_yaw = @cos(adjusted_yaw);
            const sin_yaw = @sin(adjusted_yaw);

            // These matrices are created in row major then transposed
            
            // Rotation around the Z plane
            const yaw = algebra.Matrix(f32, 3, 3).of(.{
                cos_yaw, -sin_yaw, 0,
                sin_yaw,  cos_yaw, 0,
                0      ,  0      , 1,
            }).transpose();
            // Rotation around the X plane
            const pitch = algebra.Matrix(f32, 3, 3).of(.{
                1, 0        ,  0        ,
                0, cos_pitch, -sin_pitch,
                0, sin_pitch,  cos_pitch,
            }).transpose();

            const column: algebra.Matrix(f32, 1, 3) = .of(.{ vector.x, vector.y, vector.z });
            const result_matrix = yaw.multiply(pitch).multiply(column);
            const result_vector: algebra.Vector3(f32) = .of(result_matrix.get(0, 0), result_matrix.get(0, 1), result_matrix.get(0, 2));
            return result_vector;
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
