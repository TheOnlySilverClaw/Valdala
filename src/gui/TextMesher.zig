const std = @import("std");
const unicode = std.unicode;
const webgpu = @import("webgpu");
const graphics = @import("graphics");
const algebra = @import("algebra");

const assert = std.debug.assert;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Font = graphics.Font;
const Vector = algebra.Vector2;
const Vertex = TextMesh.Vertex;
const Text = @import("Text.zig");
const TextMesh = @import("TextMesh.zig");


const Self = @This();

const glyph_vertex_count = 6;


pub fn generate(allocator: Allocator, surface: *const graphics.Surface, text: Text) !TextMesh {

    const device = surface.device;
    
    const glyph_count = try unicode.utf8CountCodepoints(text.value);
    const vertex_count: u32 = @intCast(glyph_count * glyph_vertex_count);

    const vertex_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = vertex_count * @sizeOf(TextMesh.Vertex),
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const vertex_buffer = surface.device.createBuffer(&vertex_buffer_descriptor);

    const index_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = vertex_count * @sizeOf(TextMesh.Index),
        .usage = .{ .index = true, .copy_dst = true }
    };

    const index_buffer = device.createBuffer(&index_buffer_descriptor);

    var vertices = try generateVertices(allocator, text, surface.width, surface.height);
    defer vertices.clearAndFree(allocator);

    const queue = surface.getQueue();
    queue.writeBuffer(vertex_buffer, TextMesh.Vertex, vertices.items, 0);

    return .{
        .vertex_buffer = vertex_buffer,
        .index_buffer = index_buffer,
        .vertex_count = vertex_count
    };
}

fn generateVertices(allocator: Allocator, text: Text, surface_width: u32, surface_height: u32) !ArrayList(Vertex) {

    const font = text.font;

    const view = try std.unicode.Utf8View.init(text.value);
    var iterator = view.iterator();
    var vertices = try ArrayList(Vertex).initCapacity(allocator, text.value.len * glyph_vertex_count);

    var offset_x: f32 = @floatFromInt(text.position.x);
    // TODO figure out recommended way to find the baseline
    const baseline: f32 = @as(f32, @floatFromInt(text.position.y)) + font.height / 2.0;

    while(iterator.nextCodepoint()) |code_point| {
        // TODO figure out whitespace distances
        if(code_point == ' ') {
            offset_x += font.height / 2.0;
            continue;
        }
        const glyph = try font.getGlyph(code_point);
        const position = Vector(f32).of(offset_x, baseline);
        const generated = try generateGlyphVertices(glyph, position, text.color, @floatFromInt(surface_width), @floatFromInt(surface_height));
        vertices.appendSliceAssumeCapacity(&generated);
        offset_x += glyph.advance;
    }

    return vertices;
}

fn generateGlyphVertices(glyph: Font.Glyph, position: Vector(f32), color_rgba: graphics.color.RGBA, surface_width: f32, surface_height: f32) ![glyph_vertex_count]Vertex {

    const start_x: f32 = position.x + glyph.offset_x;
    const start_y: f32 = position.y + glyph.offset_y;
    const end_x: f32 = start_x + glyph.width;
    const end_y: f32 = start_y + glyph.height;

    const start_x_norm = 2.0 * start_x / surface_width - 1.0;
    const end_x_norm = 2.0 *  end_x / surface_width - 1.0;
    const start_y_norm = 1.0 - 2 * start_y / surface_height;
    const end_y_norm = 1.0 - 2 * end_y / surface_height;

    const uv = glyph.texture_slice;

    const color = Vertex.Color {
        .red = color_rgba.red,
        .green = color_rgba.green,
        .blue = color_rgba.blue,
        .alpha = color_rgba.alpha,
    };

    const top_left = Vertex {
        .position = .{
            .x = start_x_norm,
            .y = start_y_norm,
        },
        .uv = .{
            .u = uv.start_x,
            .v = uv.start_y,
        },
        .color = color
    };

    const bottom_left = Vertex {
        .position = .{
            .x = start_x_norm,
            .y = end_y_norm,
        },
        .uv = .{
            .u = uv.start_x,
            .v = uv.end_y,
        },
        .color = color
    };

    const bottom_right = Vertex {
        .position = .{
            .x = end_x_norm,
            .y = end_y_norm,
        },
        .uv = .{
            .u = uv.end_x,
            .v = uv.end_y,
        },
        .color = color
    };

    const top_right = Vertex {
        .position = .{
            .x = end_x_norm,
            .y = start_y_norm,
        },
        .uv = .{
            .u = uv.end_x,
            .v = uv.start_y,
        },
        .color = color
    };

    return .{
        top_left,
        bottom_left,
        bottom_right,
        bottom_right,
        top_right,
        top_left
    };
}