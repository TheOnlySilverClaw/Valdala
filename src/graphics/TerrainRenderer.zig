const std = @import("std");
const webgpu = @import("webgpu");
const algebra = @import("algebra");
const module = @import("module");
const log = std.log.scoped(.terrain_renderer);

const Allocator = std.mem.Allocator;
const Scene = @import("scene").Scene;
const Surface = @import("Surface.zig");
const Pipeline = @import("TerrainRenderPipeline.zig");
const AssetLoader = @import("asset").AssetLoader;
const ChunkMesh = @import("scene").ChunkMesh;
const TextureArray = @import("TextureArray.zig");

const Self = @This();

surface: *const Surface,
pipeline: Pipeline,
projection_buffer: *webgpu.buffer.Buffer,
sampler: *webgpu.sampler.Sampler,
tile_texture_view: *webgpu.texture_view.TextureView,
bindgroup: *webgpu.bind_group.BindGroup,


pub fn init(surface: *const Surface, tile_textures: TextureArray) !Self {

    const device = surface.device;

    const pipeline = try Pipeline.init(surface);
    const bindgroup_layout = pipeline.handle.getBindGroupLayout(0);

    const projection_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .label = .sliced("projection"),
        .size = 4 * 4 * @sizeOf(f32),
        .usage = .{ .vertex = true, .uniform = true, .copy_dst = true }
    };

    const projection_buffer = device.createBuffer(&projection_buffer_descriptor);

    const projection_buffer_entry = webgpu.bind_group.BindGroupEntry {
        .binding = 0,
        .buffer = projection_buffer,
        .size = projection_buffer.size()
    };

    const sampler_descriptor = webgpu.sampler.SamplerDescriptor {
        .address_mode_u = .repeat,
        .address_mode_v = .repeat,
        .address_mode_w = .undefined,
        .mag_filter = .nearest,
        .min_filter = .nearest,
        .mipmap_filter = .nearest
    };

    const sampler = device.createSampler(&sampler_descriptor);

    const Entry = webgpu.bind_group.BindGroupEntry;

    const sampler_entry = Entry {
        .binding = 1,
        .sampler = sampler
    };

    // omitting the descriptor only works if the texture array has more than 1 element!
    const tile_texture_view = tile_textures.createView(.{
        .label = webgpu.StringView.sliced("terrain")
    });

    const terrain_texture_entry = Entry {
        .binding = 2,
        .texture_view = tile_texture_view
    };

    const entries = [_] Entry {
        projection_buffer_entry,
        sampler_entry,
        terrain_texture_entry
    };

    const descriptor = webgpu.bind_group.BindGroupDescriptor {
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
        .tile_texture_view = tile_texture_view,
        .sampler = sampler
    };
}

pub fn render(self: *Self, scene: Scene, render_pass: *webgpu.render_pass_encoder.RenderPassEncoder) !void {
     
     const surface = self.surface;
     const queue = surface.getQueue();

     render_pass.setPipeline(self.pipeline.handle);
     render_pass.setBindGroup(0, self.bindgroup, null);

    const view_matrix = scene.camera.toMatrix();

    queue.writeBuffer(self.projection_buffer, f32, &view_matrix.values, 0);

    var chunk_mesh_iterator = scene.chunks.valueIterator();
    while(chunk_mesh_iterator.next()) |chunk_mesh| {
        try renderChunk(chunk_mesh, render_pass);
    }
}

pub fn renderChunk(mesh: *const ChunkMesh, render_pass: *webgpu.render_pass_encoder.RenderPassEncoder) !void {

    render_pass.setVertexBuffer(0, mesh.vertex_buffer, 0, mesh.vertex_buffer.size());
    render_pass.setIndexBuffer(mesh.index_buffer, .uint32, 0, mesh.index_buffer.size());
    render_pass.drawIndexed(@intCast(mesh.index_buffer.size() / @sizeOf(ChunkMesh.Index)), 1, 0, 0, 0);
}

pub fn deinit(self: Self) void {
    self.pipeline.deinit();
    self.tile_texture_view.release();
}