const std = @import("std");
const glfw = @import("glfw");
const event = @import("event.zig");
const graphics = @import("graphics");
const log = std.log.scoped(.controller);

const Allocator = std.mem.Allocator;
const Window = @import("Window.zig");
const Scene = @import("scene").Scene;

const Self = @This();

allocator: Allocator,
window: *Window,
renderer: *graphics.GameRenderer,
scene: *Scene,
create_screenshot: bool,

pub fn init(allocator: Allocator, window: *Window, renderer: *graphics.GameRenderer, scene: *Scene) Self {
    return .{
        .allocator = allocator,
        .window = window,
        .renderer = renderer,
        .scene = scene,
        .create_screenshot = false
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
    
    if(action == .release) {
        switch (key) {
            // This only sets a flag on the window. Actually closes at the end of the update.
            .escape => self.window.close(),
            .f5 => self.create_screenshot = true,
            else => log.debug("unbound key {s} {s} {s} {s}", .{
                @tagName(key),
                @tagName(action),
                if(modifiers.shift) "shift" else "",
                if(modifiers.alt) "alt" else ""
            })
        }
    }
}

pub fn update(self: *Self) !void {
    
    glfw.pollEvents();
    
    if(self.create_screenshot) {
        var screenhot: graphics.Screenshot = undefined;
        defer screenhot.deinit();

        try self.renderer.renderScene(self.scene, &screenhot);
        self.create_screenshot = false;

        try screenhot.save(&self.allocator);
    } else {
        try self.renderer.renderScene(self.scene, null);
    }
}

pub fn done(self: Self) bool {
    return self.window.shouldClose();
}