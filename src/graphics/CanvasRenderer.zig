const std = @import("std");
const webgpu = @import("webgpu");
const gui = @import("gui");

const Allocator = std.mem.Allocator;
const Canvas = gui.Canvas;
const Surface = @import("Surface.zig");
const TextRenderer = @import("TextRenderer.zig");
const Font = @import("Font.zig");

const Self = @This();


surface: *const Surface,
text_renderer: TextRenderer,

pub fn init(surface: *const Surface, fonts: []const Font) !Self {

    const text_renderer = try TextRenderer.init(surface, fonts);

    return .{
        .surface = surface,
        .text_renderer = text_renderer
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
    
    try self.text_renderer.render(canvas.texts, render_pass);

    render_pass.end();
    render_pass.release();
}