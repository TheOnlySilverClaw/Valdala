const std = @import("std");
const fmt = std.fmt;
const time = std.time;
const asset = @import("asset");
const graphics = @import("graphics");
const algebra = @import("algebra");

const Allocator = std.mem.Allocator;
const Surface = graphics.Surface;
const Font = graphics.Font;
const Canvas = @import("Canvas.zig");
const Vector = algebra.Vector3;
const Quaternion = algebra.Quaternion;

const Self = @This();

allocator: Allocator,
canvas: Canvas,
frame_time: u64,
frame_time_element: *Canvas.TextElement,
position: Vector(f32),
position_element: *Canvas.TextElement,
rotation: Quaternion(f32),
rotation_element: *Canvas.TextElement,

pub fn init(allocator: Allocator, surface: *const Surface, fonts: []Font) !Self {

    var canvas = try Canvas.init(allocator, surface);
    const font = &fonts[0];

    const frame_time_element = try canvas.createText(.{ .value = "", .position = .of(10, 20), .font = font });
    const position_element = try canvas.createText(.{ .value = "", .position = .of(10, 50), .font = font });
    const rotation_element = try canvas.createText(.{ .value = "", .position = .of(10, 80), .font = font });

    return .{
        .allocator = allocator,
        .canvas = canvas,
        .frame_time = undefined,
        .frame_time_element = frame_time_element,
        .position = undefined,
        .position_element = position_element,
        .rotation = undefined,
        .rotation_element = rotation_element
    };
}

pub fn deinit(self: *Self) void {
    self.canvas.deinit();
}

pub fn update(self: *Self) !void {

    var buffer: [1024]u8 = undefined;
    var canvas = &self.canvas;

    const frame_time_ms = self.frame_time / 1000;
    const frames_per_second: f32 = time.ns_per_s / @as(f32, @floatFromInt(self.frame_time));
    const frame_time_value = try fmt.bufPrint(&buffer, "Performance:  {d:.1} fps  {d:>8} ms", .{ frames_per_second, frame_time_ms });
    self.frame_time_element.text.value = frame_time_value;
    try canvas.updateText(self.frame_time_element);

    const position_value = try fmt.bufPrint(&buffer, "Position:  x {d:>.2} y {d:>.2} z {d:>.2}", .{ self.position.x, self.position.y, self.position.z });
    self.position_element.text.value = position_value;
    try canvas.updateText(self.position_element);

    const rotation_value = try fmt.bufPrint(&buffer, "Rotation:  x {d:>.2} y {d:>.2} z {d:>.2} w {d:>.2}", .{ self.rotation.x, self.rotation.y, self.rotation.z, self.rotation.w });
    self.rotation_element.text.value = rotation_value;
    try canvas.updateText(self.rotation_element);
}