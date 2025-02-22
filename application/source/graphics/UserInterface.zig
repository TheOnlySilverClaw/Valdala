const std = @import("std");

const Allocator = std.mem.Allocator;
const FontTexture = @import("FontTexture.zig");
const Surface = @import("Surface.zig");
const DebugOverlay = @import("DebugOverlay.zig");
const TextRenderer = @import("TextRenderer.zig");
const Scene = @import("Scene.zig");

const Self = @This();

allocator: Allocator,
textRenderer: TextRenderer,
debugOverlay: DebugOverlay,

surface: *const Surface,
scene: *const Scene,

pub fn init(allocator: Allocator, scene: *Scene, surface: *const Surface) !Self {

    var textRenderer = try TextRenderer.init(allocator, surface);
    const debugOverlay = DebugOverlay.init(allocator, surface.device, &textRenderer.fontTexture);

    return .{
        .allocator = allocator,
        .textRenderer = textRenderer,
        .debugOverlay = debugOverlay,
        .scene = scene,
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