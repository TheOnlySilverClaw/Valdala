const std = @import("std");
const webgpu = @import("webgpu");

const Scene = @import("scene").Scene;
const Surface = @import("Surface.zig");
const EntityRenderer = @import("EntityRenderer.zig");
const TerrainRenderer = @import("TerrainRenderer.zig");
const TextureArray = @import("TextureArray.zig");
const TextureList = @import("TextureList.zig");

const Self = @This();


surface: *const Surface,
terrain_renderer: TerrainRenderer,
entity_renderer: EntityRenderer,

pub fn init(surface: *const Surface, tile_textures: TextureArray, entity_textures: TextureList) !Self {

    const terrain_renderer = try TerrainRenderer.init( surface, tile_textures);
    const entity_renderer =  try EntityRenderer.init(surface, entity_textures);

    return .{
        .surface = surface,
        .terrain_renderer = terrain_renderer,
        .entity_renderer = entity_renderer
    };
}

pub fn render(self: *Self, scene: Scene, command_encoder: *webgpu.command_encoder.CommandEncoder, color_texture: *webgpu.texture_view.TextureView, depth_texture: *webgpu.texture_view.TextureView) !void {

    const clear_color = webgpu.Color {
        .r = scene.sky_color.red,
        .g = scene.sky_color.green,
        .b = scene.sky_color.blue,
        .a = 1.0
    };

    const color_attachment = webgpu.render_pass_encoder.RenderPassColorAttachment {
        .clear_value = clear_color,
        .load_op = .clear,
        .store_op = .store,
        .view = color_texture
    };

    const depth_stencil_attachment = webgpu.render_pass_encoder.RenderPassDepthStencilAttachment {
        .depth_load_op = .clear,
        .depth_store_op = .store,
        .depth_clear_value = 1.0,
        .view = depth_texture,
        .stencil_read_only = 0
    };

    const render_pass_descriptor = webgpu.render_pass_encoder.RenderPassDescriptor {
        .color_attachment_count = 1,
        .color_attachments = &.{ color_attachment },
        .depth_stencil_attachment = &depth_stencil_attachment
    };

    const render_pass = command_encoder.beginRenderPass(&render_pass_descriptor);
    
    try self.terrain_renderer.render(scene, render_pass);
    try self.entity_renderer.render(scene, render_pass);

    render_pass.end();
    render_pass.release();
}

pub fn deinit(self: Self) void {
    _ = self;
}