const std = @import("std");
const glfw = @import("glfw");
const algreba =  @import("algebra");

const Window = @import("Window.zig");
const Camera = @import("Camera.zig");

const log = std.log;

const Self = @This();

window: *Window,
camera: *Camera,

pub fn onKey(self: Self, key: glfw.Key, action: glfw.Action, modifiers: glfw.Modifiers) void {

    if(action == .press or action == .repeat) {
        switch (key) {
            .d => self.camera.transform.translatePitch(0.2),
            .a => self.camera.transform.translatePitch(-0.2),
            .w => self.camera.transform.translateRoll(0.2),
            .s => self.camera.transform.translateRoll(-0.2),
            .j => self.camera.transform.rotateYaw(-0.1),
            .l => self.camera.transform.rotateYaw(0.1),
            .i => self.camera.transform.rotatePitch(0.1),
            .k => self.camera.transform.rotatePitch(-0.1),
            .u => self.camera.transform.rotateRoll(-0.1),
            .o => self.camera.transform.rotateRoll(0.1),
            .zero => self.camera.transform = algreba.Transform(f32).origin(),
            else => {
                log.debug("unmapped key {} action {s} shift: {} control: {}",
            .{ key, @tagName(action), modifiers.shift, modifiers.control});
            }
        }
    }
}