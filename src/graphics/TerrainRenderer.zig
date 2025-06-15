const std = @import("std");
const webgpu = @import("webgpu");
const log = std.log.scoped(.terrain);

const Scene = @import("scene").Scene;
const Chunk = @import("scene").Chunk;

const Surface = @import("Surface.zig");
const Pipeline = @import("TerrainRenderPipeline.zig");
const AssetLoader = @import("asset").AssetLoader;
const ChunkMesh = @import("ChunkMesh.zig");

const Self = @This();

surface: *const Surface,
pipeline: Pipeline,

pub fn init(surface: *const Surface, asset_loader: *AssetLoader) !Self {

    const texture_paths = [_][]const u8 {
        "testing/texture_1.qoi",
        "testing/texture_2.qoi",
        "testing/texture_3.qoi",
        "testing/texture_4.qoi",
    };

    const textures = try asset_loader.loadTextureArray(texture_paths[0..], 16, 16, surface.getColorTextureFormat(), .{ .label = .sized("terrain")});
    const texture_view = textures.createView(null);
    log.debug("loaded terrain textures {}", .{ texture_view });

    const pipeline = try Pipeline.init(surface, asset_loader);
    return .{
        .surface = surface,
        .pipeline = pipeline
    };
}

pub fn render(self: *Self, scene: *const Scene, render_pass: *webgpu.RenderPassEncoder) !void {
     
     for(scene.chunks) |*chunk| {
        try self.renderChunk(chunk, render_pass);
     }
}

pub fn renderChunk(self: *Self, chunk: *Chunk, render_pass: *webgpu.RenderPassEncoder) !void {

    const mesh = ChunkMesh.generate(chunk, self.surface.device);
    render_pass.setVertexBuffer(0, mesh.vertex_buffer, 0, mesh.vertex_buffer.size());
}

pub fn deinit(self: Self) void {
    self.pipeline.deinit();
}