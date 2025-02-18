const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Pipeline = @import("TextRenderPipeline.zig");
const Color = @import("color.zig").Color(f32);
const Surface = @import("Surface.zig");
const Shader = @import("shader.zig").Shader;
const FontTexture = @import("FontTexture.zig");
const Sampler = @import("Sampler.zig");
const VertexBuffer = @import("VertexBuffer.zig").VertexBuffer;
const ArrayList = std.ArrayListUnmanaged;

const Vertex = extern struct {
    x: f32,
    y: f32,
    u: f32,
    v: f32
};

const Self = @This();

allocator: Allocator,
pipeline: Pipeline,
fontTexture: FontTexture,
surface: Surface,
samplerBindGroup: webgpu.BindGroup,
variableBindGroup: webgpu.BindGroup,
vertexBuffer: VertexBuffer(Vertex, &.{ .float32x2, .float32x2 }),


pub fn init(allocator: Allocator, surface: Surface) !Self {

    const device = surface.device;

    const shader = try Shader.loadModule(allocator, device, "shaders/text.wgsl", "text");

    const pipeline = Pipeline.create(device, surface.colorTextureFormat, shader);

    const fontSize = 24;

    const fontBytes = try std.fs.cwd().readFileAlloc(allocator, "fonts/FiraCode/FiraCode-Regular.ttf", 1_000_000);
    var fontTexure = try FontTexture.init(allocator, device, fontBytes, fontSize, 127);
    try fontTexure.loadASCII();

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
        .texture_view = fontTexure.createView()
    };

    const screenSizeBuffer = device.createBuffer(&webgpu.BufferDescriptor {
        .label = "screen size",
        .size = @sizeOf([2]f32),
        .usage = .{ .uniform = true, .copy_dst = true }
    });

    const screenSize = [2]f32 {
        @floatFromInt(surface.width),
        @floatFromInt(surface.height)
    };

    surface.getQueue().writeBuffer(screenSizeBuffer, f32, &screenSize, 0);

    const screenSizeEntry = webgpu.BindGroupEntry {
        .binding = 1,
        .buffer = screenSizeBuffer,
        .size = screenSizeBuffer.size(),
        .offset = 0
    };

    const textColorBuffer = device.createBuffer(&webgpu.BufferDescriptor {
        .label = "text color",
        .size = @sizeOf(Color) * 1,
        .usage = .{ .uniform = true, .copy_dst = true }
    });

    const color = Color.rgb(1, 16.0 / 255.0, 240.0 / 255.0);
    surface.queue.writeBuffer(textColorBuffer, Color, &.{ color }, 0);

    const textColorEntry = webgpu.BindGroupEntry {
        .binding = 2,
        .buffer = textColorBuffer,
        .size = textColorBuffer.size(),
        .offset = 0
    };

    const variableEntries = [_] webgpu.BindGroupEntry {
        textureEntry,
        screenSizeEntry,
        textColorEntry
    };

    const variableGroupDescriptor = webgpu.BindGroupDescriptor {
        .entries = variableEntries[0..],
        .entry_count = variableEntries.len,
        .layout = pipeline.handle.getBindGroupLayout(1)
    };
    const variableBindGroup = device.createBindGroup(&variableGroupDescriptor);


    var vertexBuffer = VertexBuffer(Vertex, &.{ .float32x2, .float32x2 }) {
        .length = 1024,
        .label = "text vertices"
    };
    vertexBuffer.create(device);

    return .{
        .allocator = allocator,
        .pipeline = pipeline,
        .fontTexture = fontTexure,
        .surface = surface,
        .samplerBindGroup = samplerBindGroup,
        .variableBindGroup = variableBindGroup,
        .vertexBuffer = vertexBuffer
    };
}

fn generateTextMesh(allocator: Allocator, text: []const u8, font: *FontTexture, x: f32, y: f32) !ArrayList(Vertex) {

    const view = try std.unicode.Utf8View.init(text);
    var iterator = view.iterator();
    var vertices = try ArrayList(Vertex).initCapacity(allocator, text.len * 6);

    var offsetX: f32 = x;
    // TODO figure out recommended way to find the baseline
    const baseLine: f32 = y + font.fontHeight / 2;

    while(iterator.nextCodepoint()) |codePoint| {
        if(codePoint == ' ') {
            offsetX += font.fontHeight / 2;
            continue;
        }
        const glyph = try font.getGlyph(codePoint);
        const generated = try generateGlyphMesh(glyph, offsetX, baseLine);
        vertices.appendSliceAssumeCapacity(&generated);
        offsetX += glyph.advance;
    }

    return vertices;
}

fn generateGlyphMesh(glyph: FontTexture.Glyph, x: f32, y: f32) ![6]Vertex {

    const startX: f32 = x + glyph.offsetX;
    const startY: f32 = y + glyph.offsetY;
    const endX: f32 = startX + glyph.width;
    const endY: f32 = startY + glyph.height;

    const uv = glyph.textureSlice;

    const topLeft = Vertex {
        .x = startX,
        .y = startY,
        .u = uv.startX,
        .v = uv.startY,
    };

    const bottomLeft = Vertex {
        .x = startX,
        .y = endY,
        .u = uv.startX,
        .v = uv.endY,
    };

    const bottomRight = Vertex {
        .x = endX,
        .y = endY,
        .u = uv.endX,
        .v = uv.endY,
    };

    const topRight = Vertex {
        .x = endX,
        .y = startY,
        .u = uv.endX,
        .v = uv.startY,
    };

    return .{
        topLeft,
        bottomLeft,
        bottomRight,
        bottomRight,
        topRight,
        topLeft
    };
}

pub fn render(self: *Self, delta: u64) !void {

    const surface = self.surface;
    const device = surface.device;
    const queue = surface.getQueue();

    const fps: f32 = @as(f32, @floatFromInt(std.time.ms_per_s)) / @as(f32, @floatFromInt(delta));
    var buffer: [20]u8 = undefined;
    const slice = try std.fmt.bufPrint(&buffer, "{d:5} ms {d:3.0} fps", .{ delta, fps });

    var vertices = try generateTextMesh(self.allocator, slice, &self.fontTexture, 10, 10);
    // TODO handle multiple different offsets
    self.vertexBuffer.upload(queue, vertices.items, 0);
    defer vertices.deinit(self.allocator);

    const commandEncoder = device.createCommandEncoder(null);
    
    const frameTexture = try surface.getColorTexture();
    const frameTextureView = frameTexture.createView(null);

    const colorAttachment = webgpu.RenderPassColorAttachment {
        .clear_value = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 1 },
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
    
    renderPassEncoder.draw(@intCast(vertices.items.len), 1, 0, 0);

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

pub fn deinit(self: *Self) void {

    self.fontTexture.deinit();
}
