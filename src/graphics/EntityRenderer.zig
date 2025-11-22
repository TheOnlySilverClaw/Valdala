const std = @import("std");
const webgpu = @import("webgpu");
const algebra = @import("algebra");
const module = @import("module");
const log = std.log.scoped(.entity_renderer);

const Allocator = std.mem.Allocator;
const Matrix = algebra.Matrix(f32, 4, 4);
const Scene = @import("scene").Scene;
const Surface = @import("Surface.zig");
const Pipeline = @import("EntityRenderPipeline.zig");
const EntityMesh = @import("scene").EntityMesh;
const TextureArray = @import("TextureArray.zig");

const Self = @This();

surface: *const Surface,
pipeline: Pipeline,
projection_buffer: *webgpu.buffer.Buffer,
transform_buffer: *webgpu.buffer.Buffer,
sampler: *webgpu.sampler.Sampler,
bindgroup: *webgpu.bind_group.BindGroup,


pub fn init(surface: *const Surface) !Self {

    const device = surface.device;

    const pipeline = try Pipeline.init(surface);
    const bindgroup_layout = pipeline.static_bind_group_layout;

    const projection_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .label = .sliced("projection"),
        .size = @sizeOf(Matrix),
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

    const entries = [_] Entry {
        projection_buffer_entry,
        sampler_entry,
    };

    const descriptor = webgpu.bind_group.BindGroupDescriptor {
        .entries = &entries,
        .entry_count = entries.len,
        .layout = bindgroup_layout
    };

    const bindgroup = surface.device.createBindGroup(&descriptor);

    const transform_buffer = createTransformBuffer(device, 64);

    return .{
        .surface = surface,
        .pipeline = pipeline,
        .bindgroup = bindgroup,
        .projection_buffer = projection_buffer,
        .transform_buffer = transform_buffer,
        .sampler = sampler
    };
}

fn createTransformBuffer(device: *webgpu.device.Device, count: u64) *webgpu.buffer.Buffer {
    
    const descriptor = webgpu.buffer.BufferDescriptor {
        .label = .sliced("transform"),
        .size = @sizeOf(Matrix) * count,
        .usage = .{ .uniform = true, .copy_dst = true }
    };

    return device.createBuffer(&descriptor);
}

pub fn render(self: *Self, scene: Scene, render_pass: *webgpu.render_pass_encoder.RenderPassEncoder) !void {
     
     const surface = self.surface;
     const queue = surface.getQueue();

     render_pass.setPipeline(self.pipeline.handle);
     render_pass.setBindGroup(0, self.bindgroup, null);

    const view_matrix = scene.camera.toMatrix();

    queue.writeBuffer(self.projection_buffer, f32, &view_matrix.values, 0);

    const transform_entry = webgpu.bind_group.BindGroupEntry {
        .binding = 0,
        .buffer = self.transform_buffer,
        .size = self.transform_buffer.size()
    };

    const dynamic_bind_group_descriptor = webgpu.bind_group.BindGroupDescriptor {
        .layout = self.pipeline.dynamic_bind_group_layout,
        .entries = &.{ transform_entry },
        .entry_count = 1
    };

    const dynamic_bind_group = surface.device.createBindGroup(&dynamic_bind_group_descriptor);
    defer dynamic_bind_group.release();

    for(scene.entities.items, 0..) |mesh, instance| {

        const dynamic_offset: u32 = @intCast(instance * @sizeOf(Matrix));
        render_pass.setBindGroup(1, dynamic_bind_group, &.{ dynamic_offset });

        const transform_matrix = mesh.transform.toMatrix();
        queue.writeBuffer(self.transform_buffer, f32, &transform_matrix.values, @sizeOf(Matrix) * instance);

        render_pass.setVertexBuffer(0, mesh.vertex_buffer, 0, mesh.vertex_buffer.size());
        render_pass.setIndexBuffer(mesh.index_buffer, .uint16, 0, mesh.index_buffer.size());
        render_pass.drawIndexed(@intCast(mesh.index_buffer.size() / @sizeOf(EntityMesh.Index)), 1, 0, 0, 0);
    }
}


pub fn deinit(self: Self) void {
    self.pipeline.deinit();
    self.tile_texture_view.release();
}