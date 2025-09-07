const std = @import("std");
const webgpu = @import("webgpu");
const asset = @import("asset");
const gui = @import("gui");
const log = std.log.scoped(.text_renderer);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Text = gui.Text;
const TextMesh = gui.TextMesh;
const Pipeline = @import("TextRenderPipeline.zig");
const Color = @import("color.zig").Color(f32);
const Surface = @import("Surface.zig");
const Shader = @import("Shader.zig");
const ImageTexture = @import("ImageTexture.zig");
const Font = @import("Font.zig");

const Self = @This();

pipeline: Pipeline,
surface: *const Surface,
sampler_bindgroup: *webgpu.BindGroup,
fonts: []const Font,

pub fn init(surface: *const Surface, fonts: []const Font) !Self {

    const device = surface.device;

    const shader_source = asset.shader.text[0..];
    const shader = Shader.load(shader_source, device, "text");

    const pipeline = Pipeline.create(device, surface.getColorTextureFormat(), shader);

    const sampler_descriptor = webgpu.SamplerDescriptor {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .undefined,
        .mag_filter = .linear,
        .min_filter = .linear,
        .mipmap_filter = .linear
    };

    const sampler = device.createSampler(&sampler_descriptor);
    defer sampler.release();

    const sampler_entry = webgpu.BindGroupEntry {
        .binding = 0,
        .sampler = sampler
    };

    const sampler_bindgroup_descriptor = webgpu.BindGroupDescriptor {
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


pub fn render(self: *Self, texts: List(Text), render_pass: *webgpu.RenderPassEncoder) !void {

    const device = self.surface.device;
    const pipeline = self.pipeline.handle;

    render_pass.setPipeline(pipeline);
    render_pass.setBindGroup(0, self.sampler_bindgroup, null);

    for(self.fonts) |font| {

        const texture_entry = webgpu.BindGroupEntry {
            .binding = 0,
            .texture_view = font.texture.createView(.{})
        };

        const variable_entries = [_] webgpu.BindGroupEntry {
            texture_entry,
        };

        const variableGroupDescriptor = webgpu.BindGroupDescriptor {
            .entries = variable_entries[0..],
            .entry_count = variable_entries.len,
            .layout = pipeline.getBindGroupLayout(1)
        };

        const variable_bindgroup = device.createBindGroup(&variableGroupDescriptor);
        defer variable_bindgroup.release();
        render_pass.setBindGroup(1, variable_bindgroup, null);
        
        // TODO filter by font
        for (texts.items) |text| {
            if(text.mesh) |mesh| {
                render_pass.setVertexBuffer(0, mesh.vertex_buffer, 0, mesh.vertex_buffer.size());
                render_pass.draw(mesh.vertex_count, 1, 0, 0);
            }
        }
    }

}

pub fn deinit(self: *Self) void {

    self.sampler_bindgroup.release();
}
