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

projection_buffer: *webgpu.Buffer,
sampler: *webgpu.Sampler,
terrain_texture: *webgpu.Texture,
terrain_texture_view: *webgpu.TextureView,
bindgroup: *const webgpu.BindGroup,


pub fn init(surface: *const Surface, asset_loader: *AssetLoader) !Self {

    const device = surface.device;

    const pipeline = try Pipeline.init(surface, asset_loader);
    const bindgroup_layout = pipeline.handle.getBindGroupLayout(0);

    const texture_paths = [_][]const u8 {
        "testing/texture_1.qoi",
        "testing/texture_2.qoi",
        "testing/texture_3.qoi",
        "testing/texture_4.qoi",
    };



    const projection_buffer_descriptor = webgpu.BufferDescriptor {
        .label = .sized("projection"),
        .mapped_at_creation = 0,
        .size = 4 * 4 * @sizeOf(f32),
        .usage = .{ .vertex = true, .uniform = true }
    };

    const projection_buffer = device.createBuffer(&projection_buffer_descriptor);

    const projection_buffer_entry = webgpu.BindGroupEntry {
        .binding = 0,
        .buffer = projection_buffer,
        .size = projection_buffer.size()
    };

    const sampler_descriptor = webgpu.SamplerDescriptor {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .mag_filter = .nearest,
        .min_filter = .nearest,
        .mipmap_filter = .nearest
    };

    const sampler = device.createSampler(&sampler_descriptor);

    const sampler_entry = webgpu.BindGroupEntry {
        .binding = 1,
        .sampler = sampler
    };

    const terrain_texture = try asset_loader.loadTextureArray(
        texture_paths[0..], 16, 16, surface.getColorTextureFormat(), .{ .label = .sized("terrain")});
    const terrain_texture_view = terrain_texture.createView(null);

    const terrain_texture_entry = webgpu.BindGroupEntry {
        .binding = 2,
        .texture_view = terrain_texture_view
    };

    const entries = [_] webgpu.BindGroupEntry {
        projection_buffer_entry,
        sampler_entry,
        terrain_texture_entry
    };

    const descriptor = webgpu.BindGroupDescriptor {
        .entries = &entries,
        .entry_count = entries.len,
        .layout = bindgroup_layout
    };

    const bindgroup = surface.device.createBindGroup(&descriptor);

    return .{
        .surface = surface,
        .pipeline = pipeline,
        .bindgroup = bindgroup,
        .projection_buffer = projection_buffer,
        .terrain_texture = terrain_texture,
        .terrain_texture_view = terrain_texture_view,
        .sampler = sampler
    };
}

pub fn render(self: *Self, scene: *const Scene, render_pass: *webgpu.RenderPassEncoder) !void {
     
     for(scene.chunks) |*chunk| {
        try self.renderChunk(chunk, render_pass);
     }
}

pub fn renderChunk(self: *Self, chunk: *Chunk, render_pass: *webgpu.RenderPassEncoder) !void {

    _ = self;
    _ = chunk;
    _ = render_pass;
    // const mesh = ChunkMesh.generate(chunk, self.surface.device);
    // render_pass.setVertexBuffer(0, mesh.vertex_buffer, 0, mesh.vertex_buffer.size());
}

pub fn deinit(self: Self) void {
    self.pipeline.deinit();
}