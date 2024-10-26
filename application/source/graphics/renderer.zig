const std = @import("std");
const Allocator = std.mem.Allocator;

const Surface = @import("surface.zig").Surface;
const webgpu = @import("webgpu");
const RenderPipeline = @import("render_pipeline.zig").RenderPipeline;

const sky_blue = webgpu.shared.Color { .r = 0.53, .g = 0.81, .b = 0.92, .a = 1.0 };

pub const RenderError = error {
};

pub const Renderer = struct {
    allocator: Allocator,
    surface: *const Surface,
    pipeline: *const RenderPipeline,

    pub fn render(self: Renderer) !void {

        const surface = self.surface;
        const device = surface.getDevice();
        const queue = surface.getQueue();
        const color_texture = try surface.getColorTexture();
        const frame = color_texture.createView(null);

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

        const render_pass_encoder = command_encoder.beginRenderPass(&descriptor);
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


    fn createUniformBuffer(self: Renderer, size: usize, label: ?[]u8) webgpu.buffer.Buffer {
        
        const descriptor = webgpu.buffer.BufferDescriptor {
            .label = label,
            .size = size,
            .usage = .{ .uniform = true, .copy_dst = true },
            .mapped_at_creation = false
        };

        return self.surface.getDevice().createBuffer(&descriptor);
    }

};