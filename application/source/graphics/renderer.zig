const std = @import("std");
const Allocator = std.mem.Allocator;

const Camera = @import("camera.zig").Camera;
const Surface = @import("surface.zig").Surface;
const webgpu = @import("webgpu");
const RenderPipeline = @import("render_pipeline.zig").RenderPipeline;
const Device = webgpu.device.Device;

const sky_blue = webgpu.shared.Color { .r = 0.53, .g = 0.81, .b = 0.92, .a = 1.0 };

pub const RenderError = error {
};

pub const Renderer = struct {

    allocator: Allocator,
    surface: *const Surface,
    camera: *Camera,
    pipeline: *const RenderPipeline,

    pub fn render(self: Renderer) !void {

        const surface = self.surface;
        const device = surface.device;
        const queue = surface.queue;
        const color_texture = try surface.getColorTexture();
        const frame = color_texture.createView(null);
        const pipeline = self.pipeline;

        const command_encoder = device.createCommandEncoder(null);
        
        const color_attachment = webgpu.render_pass_encoder.RenderPassColorAttachment {
            .clear_value = sky_blue,
            .load_op = .clear,
            .store_op = .store,
            .view = frame
        };

        const descriptor = webgpu.render_pass_encoder.RenderPassDescriptor {
            .color_attachment_count = 1,
            .color_attachments = &.{color_attachment},
            .depth_stencil_attachment = null,
        };

        const block_texture_view = pipeline.block_texture.createView();
        defer block_texture_view.release();

        const projection_buffer = createUniformBuffer(device, 4*4*@sizeOf(f32), "projection");
        defer {
            projection_buffer.destroy();
            projection_buffer.release();
        }

        self.camera.transform.rotateRoll(0.01);
        
        var projection = self.camera.asMatrix();

        queue.writeBuffer(projection_buffer, f32, &projection.values, 0);

        const bind_group_entries = [_]webgpu.bind_group.BindGroupEntry {
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

        const bind_group_descriptor = webgpu.bind_group.BindGroupDescriptor {
            .layout = pipeline.bind_group_layout,
            .entry_count = bind_group_entries.len,
            .entries = &bind_group_entries
        };

        const bind_group = device.createBindGroup(&bind_group_descriptor);
        defer bind_group.release();

        const render_pass_encoder = command_encoder.beginRenderPass(&descriptor);

        render_pass_encoder.setPipeline(self.pipeline.handle);
        render_pass_encoder.setBindGroup(0, bind_group, null);
        render_pass_encoder.setVertexBuffer(0, pipeline.vertex_buffer.handle, 0, pipeline.vertex_buffer.size());
        render_pass_encoder.setIndexBuffer(pipeline.index_buffer, .uint16, 0, pipeline.index_buffer.size());
        render_pass_encoder.drawIndexed(6, 1, 0, 0, 0);

        render_pass_encoder.end();
        render_pass_encoder.release();

        const command_buffer = command_encoder.finish(null);
        command_encoder.release();

        queue.submit(&.{command_buffer});
        command_buffer.release();
        
        surface.present();
        
        frame.release();
        color_texture.release();
    }


    fn createUniformBuffer(device: Device, size: usize, label: ?[*:0]const u8) webgpu.buffer.Buffer {
        
        const descriptor = webgpu.buffer.BufferDescriptor {
            .label = label,
            .size = size,
            .usage = .{ .uniform = true, .copy_dst = true },
            .mapped_at_creation = false
        };

        return device.createBuffer(&descriptor);
    }

};