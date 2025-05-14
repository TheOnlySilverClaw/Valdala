const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const SceneRenderer = @import("SceneRenderer.zig");
const Scene = @import("scene").Scene;
const Surface = @import("Surface.zig");

const Self = @This();

surface: *Surface,
scene_renderer: *SceneRenderer,

pub fn init(allocator: Allocator, surface: *Surface) !Self {

    const scene_renderer = try allocator.create(SceneRenderer);
    scene_renderer.* = try SceneRenderer.init(surface);

    return .{
        .surface = surface,
        .scene_renderer = scene_renderer
    };
}

pub fn renderScene(self: *Self, scene: *const Scene) !void {
    try self.scene_renderer.render(scene);
}

pub fn deinit(self: Self, allocator: Allocator) void {
    
    self.scene_renderer.deinit();
    allocator.destroy(self.scene_renderer);
}