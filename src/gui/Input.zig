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
            .direction = .zero
        }
    };
}

pub const Movement = struct {
    direction: algebra.Vector3(f32),
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
