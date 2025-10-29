const std = @import("std");
const glfw = @import("glfw");
const algebra = @import("algebra");
const log = std.log.scoped(.controller);


const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Window = @import("Window.zig");
const Input = @import("Input.zig");
const listeners = @import("listeners.zig");

const Self = @This();

// Currently held down direction keys
const DirectionKeysActive = packed struct {
    left: bool = false,
    right: bool = false,
    forwards: bool = false,
    backwards: bool = false,
    up: bool = false,
    down: bool = false,
};

input: Input,

// A store of the currently held down keys to avoid using key repeat events.
direction_keys_active: DirectionKeysActive = .{},

mouse_position: algebra.Vector2(f32) = .zero,

window_size: algebra.Vector2(f32) = .zero,

pub fn new() Self {
    return .{
        .input = Input.new()
    };
}

pub fn registerWindowListeners(self: *Self, window: *Window) !void {
    
    window.event_listener = .{
        .ptr = self,
        .call = &Self.onEvent
    };
}

fn onEvent(ptr: *anyopaque, event: listeners.WindowingEvent) void {
    var self: *Self = @ptrCast(@alignCast(ptr));
    switch (event) {
        .resize => |size| self.onResize(size.width, size.height),
        .close => self.onClose(),
        .key => |key| self.onKey(key.key ,key.action, key.modifiers),
        .mouseMove => |position| self.mouse_position = position,
        else => {}
    }
}

fn isActive(action: glfw.input.Action) bool {
    return action != glfw.input.Action.release;
}

pub fn onKey(self: *Self, key: glfw.keyboard.Key, action: glfw.input.Action, modifiers: glfw.input.Modifiers) void {
    const input = &self.input;
    var window = &input.window;

    switch (key) {
        .escape => window.close = true,
        .w => self.direction_keys_active.forwards  = isActive(action),
        .a => self.direction_keys_active.left      = isActive(action),
        .s => self.direction_keys_active.backwards = isActive(action),
        .d => self.direction_keys_active.right     = isActive(action),
        .e => self.direction_keys_active.up        = isActive(action),
        .q => self.direction_keys_active.down      = isActive(action),
        else => {
            log.debug("unbound key {s} {s} {s} {s}", .{
            @tagName(key),
            @tagName(action),
            if(modifiers.shift) "shift" else "",
            if(modifiers.alt) "alt" else ""});
            return;
        }
    }
}

pub fn onResize(self: *Self, width: u32, height: u32) void {
    self.input.window.resize = .{
        .size = .{
            .width = width,
            .height = height
        }
    };
    self.window_size = .of(@floatFromInt(width), @floatFromInt(height));
}

pub fn onClose(self: *Self) void {
    self.input.window.close = true;
}

fn f32FromBool(value: bool) f32 {
    return @floatFromInt(@intFromBool(value));
}

pub fn poll(self: *Self) Input {
    
    glfw.pollEvents();
    self.input.movement.direction = .of(
        f32FromBool(self.direction_keys_active.right)    - f32FromBool(self.direction_keys_active.left),
        f32FromBool(self.direction_keys_active.forwards) - f32FromBool(self.direction_keys_active.backwards),
        f32FromBool(self.direction_keys_active.up)       - f32FromBool(self.direction_keys_active.down),
    );
    // Stop diagonal movement from being faster
    self.input.movement.direction = self.input.movement.direction.normalize() catch .zero;

    var pitch = std.math.pi * self.mouse_position.y / self.window_size.y;
    var yaw = std.math.pi * 2 * self.mouse_position.x / self.window_size.x;
    if (!std.math.isFinite(yaw)) {
        yaw = 0;
    }
    if (!std.math.isFinite(pitch)) {
        pitch = 0;
    }

    self.input.movement.rotation = .{ .pitch =  pitch, .yaw = yaw };


    const snapshot = self.input;
    self.input = Input.new();
    return snapshot;
}
