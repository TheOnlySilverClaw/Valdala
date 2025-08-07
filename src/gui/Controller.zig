const std = @import("std");
const glfw = @import("glfw");
const event = @import("event.zig");
const scene = @import("scene");
const log = std.log.scoped(.controller);


const Allocator = std.mem.Allocator;
const Window = @import("Window.zig");
const Camera = scene.Camera;

const Self = @This();

window: *Window,
camera: ?*Camera,

pub fn init(window: *Window) Self {
    return .{
        .window = window,
        .camera = null
    };
}

pub fn registerWindowListeners(self: *Self) !void {
    
    try self.window.createKeyListener(.{
        .ptr = self,
        .call = &Self.onKey
    });
}

pub fn onKey(ptr: *anyopaque, key: glfw.Key, action: glfw.Action, modifiers: glfw.Modifiers) void {
    
    // TODO is there any better way?
    const self: *Self = @ptrCast(@alignCast(ptr));

    switch (key) {
        .escape => self.window.close(),
        .n => if(self.camera) |c| c.zoomIn(0.1),
        .m => if(self.camera) |c| c.zoomOut(0.1),
        .q => if(self.camera) |c| c.moveYaw(-0.1),
        .e => if(self.camera) |c| c.moveYaw(0.1),
        .a => if(self.camera) |c| c.movePitch(-0.1),
        .d => if(self.camera) |c| c.movePitch(0.1),
        .w => if(self.camera) |c| c.moveRoll(0.1),
        .s => if(self.camera) |c| c.moveRoll(-0.1),
        .j => if(self.camera) |c| c.rotateRoll(-0.1),
        .l => if(self.camera) |c| c.rotateRoll(0.1),
        .k => if(self.camera) |c| c.rotatePitch(-0.1),
        .i => if(self.camera) |c| c.rotatePitch(0.1),
        .u => if(self.camera) |c| c.rotateYaw(-0.1),
        .o => if(self.camera) |c| c.rotateYaw(0.1),
        else => log.debug("unbound key {s} {s} {s} {s}", .{
            @tagName(key),
            @tagName(action),
            if(modifiers.shift) "shift" else "",
            if(modifiers.alt) "alt" else ""
        })
    }
}

pub fn update(self: Self) void {
    _= self;
}