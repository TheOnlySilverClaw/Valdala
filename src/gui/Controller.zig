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

// Directions that you can move in. Used to record the active directions
const Direction = enum { Left, Right, Forwards, Backwards, Up, Down};
const NumberOfDirections = @typeInfo(Direction).@"enum".fields.len;

input: Input,

// A store of the currently held down keys to avoid using key repeat events.
directions_active: [NumberOfDirections]bool = .{false} ** NumberOfDirections,

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

fn setDirectionActive(self: *Self, direction: Direction, action: glfw.input.Action) void {
    self.directions_active[@intFromEnum(direction)] = (action != glfw.input.Action.release);
}

fn movementFromDirection(self: Self, direction: Direction) f32 {
    return @floatFromInt(@intFromBool(self.directions_active[@intFromEnum(direction)])) ;
}

pub fn onKey(self: *Self, key: glfw.keyboard.Key, action: glfw.input.Action, modifiers: glfw.input.Modifiers) void {
    const input = &self.input;
    var window = &input.window;

    switch (key) {
        .escape => window.close = true,
        .w => self.setDirectionActive(Direction.Forwards, action),
        .a => self.setDirectionActive(Direction.Left, action),
        .s => self.setDirectionActive(Direction.Backwards, action),
        .d => self.setDirectionActive(Direction.Right, action),
        .e => self.setDirectionActive(Direction.Up, action),
        .q => self.setDirectionActive(Direction.Down, action),
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

pub fn poll(self: *Self) Input {
    
    glfw.pollEvents();
    self.input.movement.direction = .of(
        self.movementFromDirection(Direction.Right) - self.movementFromDirection(Direction.Left),
        self.movementFromDirection(Direction.Forwards) - self.movementFromDirection(Direction.Backwards),
        self.movementFromDirection(Direction.Up) - self.movementFromDirection(Direction.Down),
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
