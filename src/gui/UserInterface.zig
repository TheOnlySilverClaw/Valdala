const std = @import("std");
const fmt = std.fmt;
const time = std.time;
const asset = @import("asset");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const Surface = graphics.Surface;
const Font = graphics.Font;
const Canvas = @import("Canvas.zig");

const Self = @This();

allocator: Allocator,
canvas: Canvas,
frame_time: u64,
frame_time_element: *Canvas.TextElement,

pub fn init(allocator: Allocator, surface: *const Surface, fonts: []Font) !Self {

    var canvas = try Canvas.init(allocator, surface);
    const font = &fonts[0];

    const frame_time_text = try canvas.createText(.{ .value = "", .position = .of(10, 20), .font = font });

    return .{
        .allocator = allocator,
        .canvas = canvas,
        .frame_time = 0,
        .frame_time_element = frame_time_text
    };
}

pub fn deinit(self: *Self) void {
    self.canvas.deinit();
}

pub fn update(self: *Self) !void {

    const allocator = self.allocator;

    const frame_time_ms = self.frame_time / 1000;
    const frames_per_second: f32 = time.ns_per_s / @as(f32, @floatFromInt(self.frame_time));
    const frame_time_string = try fmt.allocPrint(allocator, "{d:.1} fps  {d:>8} ms", .{ frames_per_second, frame_time_ms });
    self.frame_time_element.text.value = frame_time_string;
    try self.canvas.updateText(self.frame_time_element);
    allocator.free(frame_time_string);

}