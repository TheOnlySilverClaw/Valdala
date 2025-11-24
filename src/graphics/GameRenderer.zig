const std = @import("std");
const webgpu = @import("webgpu");
const gui = @import("gui");

const Allocator = std.mem.Allocator;
const Canvas = gui.Canvas;
const Scene = @import("scene").Scene;
const SceneRenderer = @import("SceneRenderer.zig");
const CanvasRenderer = @import("CanvasRenderer.zig");
const Surface = @import("Surface.zig");
const TextureArray = @import("TextureArray.zig");
const TextureList = @import("TextureList.zig");
const Font = @import("Font.zig");

const Self = @This();

surface: *Surface,
scene_renderer: SceneRenderer,
canvas_renderer: CanvasRenderer,

pub fn init(surface: *Surface, tile_textures: TextureArray, entity_textures: TextureList, fonts: []const Font) !Self {

    const scene_renderer = try SceneRenderer.init(surface, tile_textures, entity_textures);
    const canvas_renderer = try CanvasRenderer.init(surface, fonts);

    return .{
        .surface = surface,
        .scene_renderer = scene_renderer,
        .canvas_renderer = canvas_renderer
    };
}

pub fn render(self: *Self, scene: Scene, canvas: Canvas) !void {
    
    const surface = self.surface;
    const device = surface.device;

    const command_encoder = device.createCommandEncoder(null);
    
    const color_texture = surface.getColorTexture() catch return;
    const color_texture_view = color_texture.createView(null);

    const depth_texture = surface.getDepthTexture() orelse return;
    const depth_texture_view_descriptor = webgpu.texture_view.TextureViewDescriptor {
        .label = webgpu.StringView.sliced("depth"),
        .aspect = .depth_only,
        .dimension = .@"2d",
        .format = surface.getDepthTextureFormat(),
        .usage = .{ .render_attachment = true }
    };
    const depth_texture_view = depth_texture.createView(&depth_texture_view_descriptor);

    try self.scene_renderer.render(scene, command_encoder, color_texture_view, depth_texture_view);
    try self.canvas_renderer.render(canvas, command_encoder, color_texture_view);

    const command_buffer = command_encoder.finish(null);
    command_encoder.release();
    
    surface.getQueue().submit(&.{ command_buffer });
    command_buffer.release();

    surface.present();

    color_texture_view.release();
    color_texture.release();

    depth_texture_view.release();
}

pub fn deinit(self: Self, allocator: Allocator) void {
    _ = allocator;
    self.scene_renderer.deinit();
}