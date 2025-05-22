const std = @import("std");
const webgpu = @import("webgpu");

const Scene = @import("scene").Scene;
const Surface = @import("Surface.zig");
const Pipeline = @import("TerrainRenderPipeline.zig");
const AssetLoader = @import("asset").AssetLoader;

const Self = @This();


pipeline: Pipeline,

pub fn init(surface: *const Surface, asset_loader: *AssetLoader) !Self {

    const pipeline = try Pipeline.init(surface, asset_loader);
    return .{
        .pipeline = pipeline
    };
}

pub fn render(self: *Self, scene: *const Scene) !void {
     _ = self;
     _ = scene;
}

pub fn deinit(self: Self) void {
    self.pipeline.deinit();
}