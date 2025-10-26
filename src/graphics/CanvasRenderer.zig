const std = @import("std");
const webgpu = @import("webgpu");
const asset = @import("asset");
const gui = @import("gui");
const log = std.log.scoped(.canvas_renderer);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Text = gui.Text;
const TextMesh = gui.TextMesh;
const Canvas = gui.Canvas;
const TextRenderPipeline = @import("TextRenderPipeline.zig");
const Surface = @import("Surface.zig");
const Shader = @import("Shader.zig");
const ImageTexture = @import("ImageTexture.zig");
const Font = @import("Font.zig");

const Self = @This();

pipeline: TextRenderPipeline,
surface: *const Surface,
sampler_bindgroup: *webgpu.bind_group.BindGroup,
fonts: []const Font,

pub fn init(surface: *const Surface, fonts: []const Font) !Self {

    const device = surface.device;

    const shader_source = asset.shader.text[0..];
    const shader = Shader.load(shader_source, device, "text");

    const pipeline = TextRenderPipeline.create(device, surface.getColorTextureFormat(), shader);

    const sampler_descriptor = webgpu.sampler.SamplerDescriptor {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .undefined,
        .mag_filter = .linear,
        .min_filter = .linear,
        .mipmap_filter = .linear
    };

    const sampler = device.createSampler(&sampler_descriptor);
    defer sampler.release();

    const sampler_entry = webgpu.bind_group.BindGroupEntry {
        .binding = 0,
        .sampler = sampler
    };

    const sampler_bindgroup_descriptor = webgpu.bind_group.BindGroupDescriptor {
        .entries = &.{ sampler_entry },
        .entry_count = 1,
        .layout = pipeline.handle.getBindGroupLayout(0)
    };

    const sampler_bindgroup = device.createBindGroup(&sampler_bindgroup_descriptor);
    
    return .{
        .pipeline = pipeline,
        .surface = surface,
        .sampler_bindgroup = sampler_bindgroup,
        .fonts = fonts
    };
}

pub fn render(self: *Self, canvas: Canvas, command_encoder: *webgpu.command_encoder.CommandEncoder, color_texture: *webgpu.texture_view.TextureView) !void {

    const clear_color = webgpu.Color {
        .r = 0.0,
        .g = 0.0,
        .b = 0.0,
        .a = 1.0
    };

    const color_attachment = webgpu.render_pass_encoder.RenderPassColorAttachment {
        .clear_value = clear_color,
        .load_op = .load,
        .store_op = .store,
        .view = color_texture
    };

    const render_pass_descriptor = webgpu.render_pass_encoder.RenderPassDescriptor {
        .color_attachment_count = 1,
        .color_attachments = &.{ color_attachment },
        .depth_stencil_attachment = null
    };

    const render_pass = command_encoder.beginRenderPass(&render_pass_descriptor);
    
    try self.renderTexts(canvas.texts.items, render_pass);

    render_pass.end();
    render_pass.release();
}

pub fn renderTexts(self: *Self, elements: []*Canvas.TextElement, render_pass: *webgpu.render_pass_encoder.RenderPassEncoder) !void {

    const device = self.surface.device;
    const pipeline = self.pipeline.handle;

    render_pass.setPipeline(pipeline);
    render_pass.setBindGroup(0, self.sampler_bindgroup, null);

    for(self.fonts) |font| {

        const texture_entry = webgpu.bind_group.BindGroupEntry {
            .binding = 0,
            .texture_view = font.texture.createView(.{})
        };

        const variable_entries = [_] webgpu.bind_group.BindGroupEntry {
            texture_entry,
        };

        const variableGroupDescriptor = webgpu.bind_group.BindGroupDescriptor {
            .entries = variable_entries[0..],
            .entry_count = variable_entries.len,
            .layout = pipeline.getBindGroupLayout(1)
        };

        const variable_bindgroup = device.createBindGroup(&variableGroupDescriptor);
        defer variable_bindgroup.release();
        render_pass.setBindGroup(1, variable_bindgroup, null);
        
        // TODO filter by font
        for(elements) |element| {
            const mesh = element.mesh;
            if(mesh.vertex_count > 0) {
                render_pass.setVertexBuffer(0, mesh.vertex_buffer, 0, mesh.vertex_buffer.size());
                render_pass.draw(mesh.vertex_count, 1, 0, 0);
            }
        }
    }

}

pub fn deinit(self: *Self) void {

    self.sampler_bindgroup.release();
}
