const std = @import("std");
const fmt = std.fmt;
const webgpu = @import("webgpu");
const algebra = @import("algebra");

const Allocator = std.mem.Allocator;
const Vector3D = algebra.Vector3D;
const Quaternion = algebra.Quaternion;

const TextMesh = @import("TextMesh.zig");
const FontTexture = @import("FontTexture.zig");


const Self = @This();

allocator: Allocator,
performanceMesh: TextMesh,
positionMesh: TextMesh,
rotationMesh: TextMesh,


pub fn init(allocator: Allocator, device: webgpu.Device, fontTexture: *FontTexture) Self {

    const performance = TextMesh.reserve(device, 32, fontTexture, .{ .x = 10, .y = 10 });
    const position = TextMesh.reserve(device, 64, fontTexture, .{ .x = 10, .y = 40 });
    const rotation = TextMesh.reserve(device, 64, fontTexture, .{ .x = 10, .y = 70 });

    return .{
        .allocator = allocator,
        .performanceMesh = performance,
        .positionMesh = position,
        .rotationMesh = rotation
    };
}

pub fn render(self: *Self, renderPass: webgpu.RenderPassEncoder, queue: webgpu.Queue, delta: u64, position: Vector3D(f32), rotation: Quaternion(f32)) !void {

    var buffer: [64]u8 = undefined;
    var slice: []const u8 = undefined;

    const fps: f32 = @as(f32, @floatFromInt(std.time.ms_per_s)) / @as(f32, @floatFromInt(delta));
    slice = try std.fmt.bufPrint(&buffer, "{d:5} ms {d:3.0} fps", .{ delta, fps });
    try self.performanceMesh.update(self.allocator, queue, slice);

    slice = try fmt.bufPrint(&buffer, "position: {d:.2}", .{ position });
    try self.positionMesh.update(self.allocator, queue, slice);

    slice = try fmt.bufPrint(&buffer, "rotation: {d:.2}", .{ rotation });
    try self.rotationMesh.update(self.allocator, queue, slice);

    self.performanceMesh.render(renderPass);
    self.positionMesh.render(renderPass);
    self.rotationMesh.render(renderPass);
}

pub fn deinit(self: Self) void {
    self.performanceMesh.destroy();
    self.positionMesh.destroy();
    self.rotationMesh.destroy();
}