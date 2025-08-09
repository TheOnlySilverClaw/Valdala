const std = @import("std");
const webgpu = @import("webgpu");
const log = std.log.scoped(.terrain);
const algebra = @import("algebra");

const Allocator = std.mem.Allocator;
const Scene = @import("scene").Scene;
const Chunk = @import("scene").Chunk;

const Surface = @import("Surface.zig");
const Pipeline = @import("TerrainRenderPipeline.zig");
const AssetLoader = @import("asset").AssetLoader;
const ChunkMesh = @import("ChunkMesh.zig");

const Self = @This();

allocator: Allocator,
surface: *const Surface,
pipeline: Pipeline,

projection_buffer: *webgpu.Buffer,
sampler: *webgpu.Sampler,
terrain_texture: *webgpu.Texture,
terrain_texture_view: *webgpu.TextureView,
bindgroup: *webgpu.BindGroup,


pub fn init(allocator: Allocator, surface: *const Surface, asset_loader: *AssetLoader) !Self {

    const device = surface.device;

    const pipeline = try Pipeline.init(surface, asset_loader);
    const bindgroup_layout = pipeline.handle.getBindGroupLayout(0);

    const texture_paths = [_][]const u8 {
        "testing/top_grass.png",
        "testing/bottom.png",
        "testing/side.png",
        "testing/inner.png",

        "testing/top_rock.png",
        "testing/bottom.png",
        "testing/side.png",
        "testing/inner.png",
    };

    const projection_buffer_descriptor = webgpu.BufferDescriptor {
        .label = .sized("projection"),
        .size = 4 * 4 * @sizeOf(f32),
        .usage = .{ .vertex = true, .uniform = true, .copy_dst = true }
    };

    const projection_buffer = device.createBuffer(&projection_buffer_descriptor);

    const projection_buffer_entry = webgpu.BindGroupEntry {
        .binding = 0,
        .buffer = projection_buffer,
        .size = projection_buffer.size()
    };

    const sampler_descriptor = webgpu.SamplerDescriptor {
        .address_mode_u = .repeat,
        .address_mode_v = .repeat,
        .address_mode_w = .undefined,
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
        texture_paths[0..], 16, 16, .{ .label = .sized("terrain")});
    // omitting the descriptor only works if the texture array has more than 1 element!
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
        .allocator = allocator,
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
     
     const surface = self.surface;
     const queue = surface.getQueue();

     render_pass.setPipeline(self.pipeline.handle);
     render_pass.setBindGroup(0, self.bindgroup, null);

    const aspect_ratio = @as(f32, @floatFromInt(surface.width)) / @as(f32, @floatFromInt(surface.height));

    var projection_matrix = algebra.Matrix(f32, 4, 4).identity;
    projection_matrix.set(1, 1, aspect_ratio);

    const view_matrix = scene.camera.toMatrix();
    const view_projection_matrix = view_matrix.multiply(projection_matrix);

    queue.writeBuffer(self.projection_buffer, f32, &view_projection_matrix.values, 0);

     for(scene.chunks) |*chunk| {
        try self.renderChunk(chunk, render_pass);
     }
}

pub fn renderChunk(self: *Self, chunk: *Chunk, render_pass: *webgpu.RenderPassEncoder) !void {

    if(chunk.mesh) |mesh| {
        render_pass.setVertexBuffer(0, mesh.vertex_buffer, 0, mesh.vertex_buffer.size());
        render_pass.setIndexBuffer(mesh.index_buffer, .uint32, 0, mesh.index_buffer.size());
        render_pass.drawIndexed(@intCast(mesh.index_buffer.size() / @sizeOf(ChunkMesh.Index)), 1, 0, 0, 0);
    } else {
        const mesh = try self.allocator.create(ChunkMesh);
        mesh.* = ChunkMesh.generate(chunk, self.surface.device);
        chunk.mesh = mesh;
    }
}

pub fn deinit(self: Self) void {
    self.pipeline.deinit();
}