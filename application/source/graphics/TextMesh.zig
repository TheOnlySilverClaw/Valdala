const std = @import("std");
const unicode = std.unicode;
const webgpu = @import("webgpu");

const assert = std.debug.assert;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const FontTexture = @import("FontTexture.zig");
const Point = @import("point.zig").Point;


const Vertex = extern struct {
    x: f32,
    y: f32,
    u: f32,
    v: f32
};

const Self = @This();

const verticesPerMesh = 6;


vertexBuffer: webgpu.Buffer,
vertexCount: u32,
fontTexture: *FontTexture,
position: Point(f32),


pub fn reserve(device: webgpu.Device, glyphCount: u32, texture: *FontTexture, position: Point(f32)) Self {

    const buffer = device.createBuffer(&webgpu.BufferDescriptor {
        .size = vertexBufferSize(glyphCount),
        .usage = .{ .vertex = true, .copy_dst = true }
    });

    return .{
        .vertexBuffer = buffer,
        .vertexCount = 0,
        .fontTexture = texture,
        .position = position
    };
}

pub fn init(allocator: Allocator, device: webgpu.Device, queue: webgpu.Queue, texture: *FontTexture, position: Point(f32), text: []const u8) !Self {

    var self = reserve(device, @intCast(text.len), texture, position);
    try self.update(allocator, queue, text);
    return self;
}

pub fn update(self: *Self, allocator: Allocator, queue: webgpu.Queue, text: []const u8) !void {

    assert(vertexBufferSize(@intCast(try unicode.utf8CountCodepoints(text))) <= self.vertexBuffer.size());

    var vertices = try generateVertices(allocator, text, self.fontTexture, self.position);
    queue.writeBuffer(self.vertexBuffer, Vertex, vertices.items, 0);
    self.vertexCount = @intCast(vertices.items.len);
    vertices.deinit(allocator);
}


pub fn destroy(self: Self) void {

    self.vertexBuffer.destroy();
    self.vertexBuffer.release();
}

pub fn render(self: Self, renderPass: webgpu.RenderPassEncoder) void {

    // set size to current vertices?
    renderPass.setVertexBuffer(0, self.vertexBuffer, 0, self.vertexBuffer.size());
    renderPass.draw(self.vertexCount, 1, 0, 0);
}


fn vertexBufferSize(glyphCount: u32) u64 {
    return glyphCount * verticesPerMesh * @sizeOf(Vertex);
}

fn generateVertices(allocator: Allocator, text: []const u8, font: *FontTexture, position: Point(f32)) !ArrayList(Vertex) {

    const view = try std.unicode.Utf8View.init(text);
    var iterator = view.iterator();
    var vertices = try ArrayList(Vertex).initCapacity(allocator, text.len * verticesPerMesh);

    var offsetX: f32 = position.x;
    // TODO figure out recommended way to find the baseline
    const baseLine: f32 = position.y + font.fontHeight / 2;

    while(iterator.nextCodepoint()) |codePoint| {
        if(codePoint == ' ') {
            offsetX += font.fontHeight / 2;
            continue;
        }
        const glyph = try font.getGlyph(codePoint);
        const generated = try generateGlyphVertices(glyph, offsetX, baseLine);
        vertices.appendSliceAssumeCapacity(&generated);
        offsetX += glyph.advance;
    }

    return vertices;
}

fn generateGlyphVertices(glyph: FontTexture.Glyph, x: f32, y: f32) ![verticesPerMesh]Vertex {

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