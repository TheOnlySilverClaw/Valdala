const std = @import("std");
const fmt = std.fmt;
const time = std.time;
const asset = @import("asset");
const graphics = @import("graphics");
const algebra = @import("algebra");
const coordinate = @import("coordinate");

const Allocator = std.mem.Allocator;
const Surface = graphics.Surface;
const Font = graphics.Font;
const Canvas = @import("Canvas.zig");
const Vector = algebra.Vector3;
const Quaternion = algebra.Quaternion;
const HexPosition = coordinate.hexagon.Position;

const Self = @This();

allocator: Allocator,
canvas: Canvas,
frame_time: u64,
frame_time_element: *Canvas.TextElement,
position: Vector(f32),
position_element: *Canvas.TextElement,
rotation: Quaternion(f32),
rotation_element: *Canvas.TextElement,
tile_position: HexPosition(i64),
tile_position_element: *Canvas.TextElement,
chunks_loaded: u32,
chunk_distance: u32,
chunks_element: *Canvas.TextElement,
chunk_position: HexPosition(i64),
chunk_position_element: *Canvas.TextElement,
step_tile_name: []const u8,
step_tile_name_element: *Canvas.TextElement,
hand_tile_name: []const u8,
hand_tile_name_element: *Canvas.TextElement,
frame_memory_usage: usize,
memory_usage_element: *Canvas.TextElement,

pub fn init(allocator: Allocator, surface: *const Surface, fonts: []Font) !Self {

    var canvas = try Canvas.init(allocator, surface);
    const font = &fonts[0];

    const frame_time_element = try canvas.createText(.{ .value = "", .position = .of(10, 20), .font = font });
    const position_element = try canvas.createText(.{ .value = "", .position = .of(10, 50), .font = font });
    const tile_position_element = try canvas.createText(.{ .value = "", .position = .of(10, 80), .font = font });
    const chunks_element = try canvas.createText(.{ .value = "", .position = .of(10, 110), .font = font });
    const chunk_position_element = try canvas.createText(.{ .value = "", .position = .of(10, 140), .font = font });
    const rotation_element = try canvas.createText(.{ .value = "", .position = .of(10, 170), .font = font });
    const step_tile_name_element = try canvas.createText(.{ .value = "", .position = .of(10, 200), .font = font });
    const hand_tile_name_element = try canvas.createText(.{ .value = "", .position = .of(10, 230), .font = font });
    const memory_usage_element = try canvas.createText(.{ .value = "", .position = .of(10, 260), .font = font });

    return .{
        .allocator = allocator,
        .canvas = canvas,
        .frame_time = undefined,
        .frame_time_element = frame_time_element,
        .position = undefined,
        .position_element = position_element,
        .tile_position = undefined,
        .tile_position_element = tile_position_element,
        .chunks_loaded = undefined,
        .chunk_distance = undefined,
        .chunks_element = chunks_element,
        .chunk_position = undefined,
        .chunk_position_element = chunk_position_element,
        .rotation = undefined,
        .rotation_element = rotation_element,
        .step_tile_name = "",
        .step_tile_name_element = step_tile_name_element,
        .hand_tile_name = "",
        .hand_tile_name_element = hand_tile_name_element,
        .frame_memory_usage = undefined,
        .memory_usage_element = memory_usage_element,
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

    const hex_position_value = try fmt.bufPrint(&buffer, "Hexagon:  n {d:>.2} se {d:>.2} h {d:>.2}", .{ self.tile_position.north, self.tile_position.south_east, self.tile_position.height });
    self.tile_position_element.text.value = hex_position_value;
    try canvas.updateText(self.tile_position_element);

    const chunks_loaded_value = try fmt.bufPrint(&buffer, "Chunks:  radius {d:>} loaded {d:>}", .{ self.chunk_distance, self.chunks_loaded });
    self.chunks_element.text.value = chunks_loaded_value;
    try canvas.updateText(self.chunks_element);

    const chunk_position_value = try fmt.bufPrint(&buffer, "Chunk:  n {d:>.2} se {d:>.2} h {d:>.2}", .{ self.chunk_position.north, self.chunk_position.south_east, self.chunk_position.height });
    self.chunk_position_element.text.value = chunk_position_value;
    try canvas.updateText(self.chunk_position_element);

    const rotation_value = try fmt.bufPrint(&buffer, "Rotation:  x {d:>.2} y {d:>.2} z {d:>.2} w {d:>.2}", .{ self.rotation.x, self.rotation.y, self.rotation.z, self.rotation.w });
    self.rotation_element.text.value = rotation_value;
    try canvas.updateText(self.rotation_element);

    const hand_tile_value = try fmt.bufPrint(&buffer, "Pointing at tile: {s}", .{ self.hand_tile_name });
    self.hand_tile_name_element.text.value = hand_tile_value;
    try canvas.updateText(self.hand_tile_name_element);

    const step_tile_value = try fmt.bufPrint(&buffer, "Standing on tile: {s}", .{ self.step_tile_name });
    self.step_tile_name_element.text.value = step_tile_value;
    try canvas.updateText(self.step_tile_name_element);

    const memory_usage_value = try fmt.bufPrint(&buffer, "Allocations: update {d:>}B", .{ self.frame_memory_usage });
    self.memory_usage_element.text.value = memory_usage_value;
    try canvas.updateText(self.memory_usage_element);
}