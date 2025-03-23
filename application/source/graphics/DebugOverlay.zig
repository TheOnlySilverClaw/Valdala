const std = @import("std");
const fmt = std.fmt;
const math = std.math;
const webgpu = @import("webgpu");
const algebra = @import("algebra");

const Allocator = std.mem.Allocator;
const Vector3 = algebra.vector.Vector3;
const Quaternion = algebra.Quaternion;

const TextMesh = @import("TextMesh.zig");
const FontTexture = @import("FontTexture.zig");

const Self = @This();


allocator: Allocator,
performanceMesh: TextMesh,
positionMesh: TextMesh,
rotationMesh: TextMesh,


pub fn init(allocator: Allocator, device: *webgpu.Device, fontTexture: *FontTexture) Self {

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

pub fn render(self: *Self, renderPass: *webgpu.RenderPassEncoder, queue: *webgpu.Queue, delta: u64, position: Vector3(f32), rotation: Quaternion(f32)) !void {

    var buffer: [64]u8 = undefined;
    var slice: []const u8 = undefined;

    const fps: f32 = @as(f32, @floatFromInt(std.time.ms_per_s)) / @as(f32, @floatFromInt(delta));
    slice = try std.fmt.bufPrint(&buffer, "{d:5} ms {d:3.0} fps", .{ delta, fps });
    try self.performanceMesh.update(self.allocator, queue, slice);

    slice = try fmt.bufPrint(&buffer, "position: x {d:5.2} y {d:5.2} z {d:5.2}", .{ position.x, position.y, position.z });
    try self.positionMesh.update(self.allocator, queue, slice);

    const angles = rotation.eulerAngles();

    const deg = math.radiansToDegrees;
    slice = try fmt.bufPrint(&buffer, "rotation: x {d:4.1}° y {d:4.1}° z {d:4.1}°", .{ deg(angles.x), deg(angles.y), deg(angles.z) });
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
