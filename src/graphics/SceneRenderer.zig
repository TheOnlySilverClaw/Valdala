const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Scene = @import("scene").Scene;
const Surface = @import("Surface.zig");
const AssetLoader = @import("asset").AssetLoader;
const TerrainRenderer = @import("TerrainRenderer.zig");
const TileRegistry = @import("module").TileRegistry;

const Self = @This();


surface: *const Surface,
terrain_renderer: TerrainRenderer,

pub fn init(allocator: Allocator, surface: *const Surface, tile_registry: TileRegistry) !Self {

    const terrain_renderer = try TerrainRenderer.init(allocator, surface, tile_registry);

    return .{
        .surface = surface,
        .terrain_renderer = terrain_renderer
    };
}

pub fn render(self: *Self, scene: Scene) !void {

    const surface = self.surface;
    const device = surface.device;
    const queue = surface.getQueue();

    const command_encoder = device.createCommandEncoder(null);
    
    const color_texture = try surface.getColorTexture();
    const color_texture_view = color_texture.createView(null);
    
    const depth_texture = surface.getDepthTexture().?;
    const depth_texture_view_descriptor = webgpu.TextureViewDescriptor {
        .label = webgpu.StringView.sized("depth"),
        .aspect = .depth_only,
        .dimension = .@"2d",
        .format = surface.getDepthTextureFormat(),
        .usage = .{ .render_attachment = true }
    };
    const depth_texture_view = depth_texture.createView(&depth_texture_view_descriptor);

    const clear_color = webgpu.Color {
        .r = scene.sky_color.red,
        .g = scene.sky_color.green,
        .b = scene.sky_color.blue,
        .a = 1.0
    };

    const color_attachment = webgpu.RenderPassColorAttachment {
        .clear_value = clear_color,
        .load_op = .clear,
        .store_op = .store,
        .view = color_texture_view
    };

    const depth_stencil_attachment = webgpu.RenderPassDepthStencilAttachment {
        .depth_load_op = .clear,
        .depth_store_op = .store,
        .depth_clear_value = 1.0,
        .view = depth_texture_view,
        .stencil_read_only = 0
    };

    const render_pass_descriptor = webgpu.RenderPassDescriptor {
        .color_attachment_count = 1,
        .color_attachments = &.{ color_attachment },
        .depth_stencil_attachment = &depth_stencil_attachment
    };

    const render_pass = command_encoder.beginRenderPass(&render_pass_descriptor);
    
    try self.terrain_renderer.render(scene, render_pass);

    render_pass.end();
    render_pass.release();

    const command_buffer = command_encoder.finish(null);
    command_encoder.release();

    queue.submit(&.{ command_buffer });
    command_buffer.release();
    
    surface.present();

    color_texture_view.release();
    color_texture.release();
    depth_texture_view.release();
}

pub fn deinit(self: Self) void {
    _ = self;
}