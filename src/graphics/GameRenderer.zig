const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const SceneRenderer = @import("SceneRenderer.zig");
const Scene = @import("scene").Scene;
const Surface = @import("Surface.zig");
const TileRegistry = @import("module").TileRegistry;

const Self = @This();

surface: *Surface,
scene_renderer: SceneRenderer,

pub fn init(allocator: Allocator, surface: *Surface, tile_registry: TileRegistry) !Self {

    const scene_renderer = try SceneRenderer.init(allocator, surface, tile_registry);

    return .{
        .surface = surface,
        .scene_renderer = scene_renderer
    };
}

pub fn renderScene(self: *Self, scene: *const Scene) !void {
    try self.scene_renderer.render(scene);
}

pub fn deinit(self: Self, allocator: Allocator) void {
    _ = allocator;
    self.scene_renderer.deinit();
}