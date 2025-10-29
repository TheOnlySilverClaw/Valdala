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

// I'm not sure if it is a good idea to store the state here?

// A store of the currently held down keys to avoid using key repeat events.
directionsActive: [NumberOfDirections]bool = .{false} ** NumberOfDirections,

mousePosition: algebra.Vector2(f32) = .zero,

windowSize: algebra.Vector2(f32) = .zero,

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
        .mouseMove => |position| self.mousePosition = position,
        else => {}
    }
}

fn setDirectionActive(self: *Self, direction: Direction, action: glfw.input.Action) void {
    self.directionsActive[@intFromEnum(direction)] = (action != glfw.input.Action.release);
}

fn movementFromDirection(self: Self, direction: Direction) f32 {
    return @floatFromInt(@intFromBool(self.directionsActive[@intFromEnum(direction)])) ;
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
    self.windowSize = .of(@floatFromInt(width), @floatFromInt(height));
}

pub fn onClose(self: *Self) void {
    self.input.window.close = true;
}

pub fn poll(self: *Self) Input {
    
    glfw.pollEvents();
    self.input.movement.direction = .of(
        self.movementFromDirection(Direction.Forwards) - self.movementFromDirection(Direction.Backwards),
        self.movementFromDirection(Direction.Right) - self.movementFromDirection(Direction.Left),
        self.movementFromDirection(Direction.Up) - self.movementFromDirection(Direction.Down),
    );
    var pitch = std.math.pi * self.mousePosition.y / self.windowSize.y;
    var yaw = std.math.pi * 2 * self.mousePosition.x / self.windowSize.x;
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
