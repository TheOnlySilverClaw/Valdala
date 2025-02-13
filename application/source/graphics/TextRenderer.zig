const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Pipeline = @import("TextRenderPipeline.zig");
const Color = @import("Color.zig").Color(f32);
const Surface = @import("Surface.zig");
const Shader = @import("shader.zig").Shader;
const Font = @import("Font.zig");
const ImageTexture = @import("ImageTexture.zig");
const Sampler = @import("Sampler.zig");
const VertexBuffer = @import("VertexBuffer.zig");

const Self = @This();


pipeline: Pipeline,
font: Font,
glyphTexture: ImageTexture,
surface: Surface,
lastGlyphStart: u32,
samplerBindGroup: webgpu.BindGroup,
variableBindGroup: webgpu.BindGroup,
vertexBuffer: VertexBuffer.VertexBuffer([4]f32, &.{ .float32x2, .float32x2 }),


pub fn init(allocator: Allocator, surface: Surface) !Self {

    const device = surface.device;

    const shader = try Shader.loadModule(allocator, device, "shaders/text.wgsl", "text");

    const pipeline = Pipeline.create(device, surface.colorTextureFormat, shader);

    var font = try Font.init(allocator, "fonts/FiraCode/FiraCode-Regular.ttf", 16);
    try font.loadASCII();

    // reserve maximum width for all glpyhs
    // TODO estimate for non-ASCII fonts with lazy-loaded glyphs
    const fontHeight: u32 = @intFromFloat(@ceil(font.size));
    const textureWidth = font.glyphByCodePoint.size * fontHeight;

    var glyphTexture = ImageTexture {
        .format = .r8_unorm,
        .height = fontHeight,
        .width = textureWidth,
        .label = "glyphs",
        .mipLevels = 1,
        .samples = 1
    };
    glyphTexture.create(surface.device);

    const sampler = Sampler.createLinearClamped(device);
    const samplerEntry = webgpu.BindGroupEntry {
        .binding = 0,
        .sampler = sampler
    };
    const samplerGroupDescriptor = webgpu.BindGroupDescriptor {
        .entries = &.{ samplerEntry },
        .entry_count = 1,
        .layout = pipeline.handle.getBindGroupLayout(0)
    };
    const samplerBindGroup = device.createBindGroup(&samplerGroupDescriptor);

    const textureEntry = webgpu.BindGroupEntry {
        .binding = 0,
        .texture_view = glyphTexture.createView()
    };

    const textColorBuffer = device.createBuffer(&webgpu.BufferDescriptor {
        .label = "text color",
        .mappedAtCreation = 0,
        .size = @sizeOf(Color) * 1,
        .usage = .{ .uniform = true, .copy_dst = true }
    });
    const color = Color.rgb(1, 1, 1);
    surface.queue.writeBuffer(textColorBuffer, Color, &.{ color }, 0);

    const textColorEntry = webgpu.BindGroupEntry {
        .binding = 1,
        .buffer = textColorBuffer,
        .size = textColorBuffer.size(),
        .offset = 0
    };

    const variableEntries: [*]const webgpu.BindGroupEntry = &.{
        textureEntry,
        textColorEntry
    };

    const variableGroupDescriptor = webgpu.BindGroupDescriptor {
        .entries = variableEntries,
        .entry_count = 2,
        .layout = pipeline.handle.getBindGroupLayout(1)
    };
    const variableBindGroup = device.createBindGroup(&variableGroupDescriptor);

    const vertices = [_][4]f32 {
        .{ -0.5, 0.5, 0, 0, },
        .{ -0.5, -0.5, 0, 1, },
        .{ 0.5, -0.5, 1, 1, },
        .{ 0.5, -0.5, 1, 1, },
        .{ 0.5, 0.5, 1, 0, },
        .{ -0.5, 0.5, 0, 0 }
    };

    var vertexBuffer = VertexBuffer.VertexBuffer([4]f32, &.{ .float32x2, .float32x2 }) {
        .length = vertices.len,
        .label = "text vertices"
    };
    vertexBuffer.create(device);

    vertexBuffer.upload(surface.getQueue(), &vertices, 0);

    return .{
        .pipeline = pipeline,
        .font = font,
        .glyphTexture = glyphTexture,
        .surface = surface,
        .lastGlyphStart = 0,
        .samplerBindGroup = samplerBindGroup,
        .variableBindGroup = variableBindGroup,
        .vertexBuffer = vertexBuffer
    };
}

pub fn render(self: Self, delta: u64) !void {

    _ = delta;

    const surface = self.surface;
    const device = surface.device;
    const queue = surface.getQueue();

    const commandEncoder = device.createCommandEncoder(null);
    
    const frameTexture = try surface.getColorTexture();
    const frameTextureView = frameTexture.createView(null);

    const colorAttachment = webgpu.RenderPassColorAttachment {
        .clear_value = .{ .r = 0.9, .g = 0.9, .b = 0.9, .a = 1 },
        .load_op = .clear,
        .store_op = .store,
        .view = frameTextureView
    };

    const renderPassDescriptor = webgpu.RenderPassDescriptor {
        .color_attachment_count = 1,
        .color_attachments = &.{ colorAttachment }
    };

    const renderPassEncoder = commandEncoder.beginRenderPass(&renderPassDescriptor);

    renderPassEncoder.setPipeline(self.pipeline.handle);
    renderPassEncoder.setBindGroup(0, self.samplerBindGroup, null);
    renderPassEncoder.setBindGroup(1, self.variableBindGroup, null);
    renderPassEncoder.setVertexBuffer(0, self.vertexBuffer.handle, 0, self.vertexBuffer.size());
    
    renderPassEncoder.draw(self.vertexBuffer.length, 1, 0, 0);

    renderPassEncoder.end();
    renderPassEncoder.release();

    const commandBuffer = commandEncoder.finish(null);
    commandEncoder.release();

    queue.submit(&.{ commandBuffer });
    commandBuffer.release();
    
    surface.present();

    frameTextureView.release();
    frameTexture.release();
}

pub fn loadFontTexture(self: *Self) !void {

    for(33..127) |i| {
        const codePoint: Font.CodePoint = @intCast(i);
        const glyph = self.font.glyphByCodePoint.get(codePoint);
        if(glyph) |g| {
            try self.loadGlyphPixels(g);
        }
    }
}

fn loadGlyphPixels(self: *Self, glyph: Font.Glyph) !void {

    if(glyph.pixels) |pixels| {
        try self.glyphTexture.loadImagePixelsRectangle(
            pixels, self.surface.getQueue(), self.lastGlyphStart, 0, glyph.width, glyph.height);
        self.lastGlyphStart += glyph.width;
    }
}

pub fn deinit(self: Self) void {

    self.font.deinit();
}
