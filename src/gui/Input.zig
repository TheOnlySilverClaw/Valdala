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
                .roll = 0
            }
        }
    };
}

pub const Movement = struct {
    direction: algebra.Vector3(f32),
    rotation: struct {
        roll: f32,
        pitch: f32,
        yaw: f32
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
