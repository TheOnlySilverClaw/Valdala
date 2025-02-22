const std = @import("std");

const Allocator = std.mem.Allocator;
const FontTexture = @import("FontTexture.zig");
const Surface = @import("Surface.zig");
const TextRenderer = @import("TextRenderer.zig");
const DebugOverlay = @import("DebugOverlay.zig");
const Scene = @import("Scene.zig");
const Window = @import("Window.zig");

const Self = @This();

allocator: Allocator,
textRenderer: TextRenderer,
debugOverlay: DebugOverlay,

window: *const Window,
scene: *const Scene,

pub fn init(allocator: Allocator, scene: *Scene, window: *const Window) !Self {

    var textRenderer = try TextRenderer.init(allocator, &window.surface);
    const debugOverlay = DebugOverlay.init(allocator, window.surface.device, &textRenderer.fontTexture);

    return .{
        .allocator = allocator,
        .textRenderer = textRenderer,
        .debugOverlay = debugOverlay,
        .scene = scene,
        .window = window
    };
}

pub fn deinit(self: *Self) void {
    self.debugOverlay.deinit();
    self.textRenderer.deinit();
}

pub fn render(self: *Self, delta: u64) !void {
    try self.textRenderer.render(delta);
}