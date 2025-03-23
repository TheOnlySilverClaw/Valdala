const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Camera = @import("Camera.zig");
const Surface = @import("Surface.zig");
const Pipeline = @import("FloorRenderPipeline.zig");

const Self = @This();


allocator: Allocator,
surface: *const Surface,
camera: *const Camera,
pipeline: *const Pipeline,


pub fn init(allocator: Allocator, surface: *const Surface, camera: *const Camera) !Self {

    const pipeline = try allocator.create(Pipeline);
    pipeline.* = try Pipeline.create(allocator, surface);

    return .{
        .allocator = allocator,
        .surface = surface,
        .pipeline = pipeline,
        .camera = camera
    };
}

pub fn render(self: Self, renderPass: *webgpu.RenderPassEncoder) !void {

    const surface = self.surface;
    const device = surface.device;
    const queue = surface.queue;
    const pipeline = self.pipeline;

    const block_texture_view = pipeline.block_texture.createView();
    defer block_texture_view.release();

    // TODO destroy buffer
    const projection_buffer = createUniformBuffer(device, 4*4*@sizeOf(f32), webgpu.StringView.sized("projection"));

    var projection = self.camera.asMatrix();
    queue.writeBuffer(projection_buffer, f32, projection.asArray(), 0);

    const bind_group_entries = [_]webgpu.BindGroupEntry {
        .{
            .binding = 0,
            .buffer = projection_buffer,
            .size = projection_buffer.size()
        },
        .{
            .binding = 1,
            .sampler = pipeline.block_sampler
        },
        .{
            .binding = 2,
            .texture_view = block_texture_view,
        }
    };

    const bind_group_descriptor = webgpu.BindGroupDescriptor {
        .layout = pipeline.bind_group_layout,
        .entry_count = bind_group_entries.len,
        .entries = &bind_group_entries
    };

    const bind_group = device.createBindGroup(&bind_group_descriptor);
    defer bind_group.release();

    renderPass.setPipeline(self.pipeline.handle);
    renderPass.setBindGroup(0, bind_group, null);
    renderPass.setVertexBuffer(0, pipeline.vertex_buffer.handle, 0, pipeline.vertex_buffer.size());
    renderPass.setIndexBuffer(pipeline.index_buffer, .uint16, 0, pipeline.index_buffer.size());
    renderPass.drawIndexed(6, 1, 0, 0, 0);
}


fn createUniformBuffer(device: *webgpu.Device, size: usize, label: webgpu.StringView) *webgpu.Buffer {
    
    const descriptor = webgpu.BufferDescriptor {
        .label = label,
        .size = size,
        .usage = .{ .uniform = true, .copy_dst = true }
    };

    return device.createBuffer(&descriptor);
}
