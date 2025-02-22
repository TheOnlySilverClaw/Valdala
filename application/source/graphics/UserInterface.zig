const std = @import("std");

const Allocator = std.mem.Allocator;
const FontTexture = @import("FontTexture.zig");
const Camera = @import("Camera.zig");
const Surface = @import("Surface.zig");
const DebugOverlay = @import("DebugOverlay.zig");
const TextRenderer = @import("TextRenderer.zig");

const Self = @This();

allocator: Allocator,
textRenderer: TextRenderer,
debugOverlay: DebugOverlay,

camera: *const Camera,
surface: *const Surface,

pub fn init(allocator: Allocator, camera: *const Camera, surface: *const Surface) !Self {

    var textRenderer = try TextRenderer.init(allocator, surface);
    const debugOverlay = DebugOverlay.init(allocator, surface.device, &textRenderer.fontTexture);

    return .{
        .allocator = allocator,
        .textRenderer = textRenderer,
        .debugOverlay = debugOverlay,
        .camera = camera,
        .surface = surface
    };
}

pub fn deinit(self: *Self) void {
    self.debugOverlay.deinit();
    self.textRenderer.deinit();
}

pub fn render(self: *Self, delta: u64) !void {
    try self.textRenderer.render(delta);
}