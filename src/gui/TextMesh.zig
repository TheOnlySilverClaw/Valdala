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

pub const Vertex = extern struct {
    
    pub const format = [_]webgpu.render_pipeline.VertexFormat {
        .float32x2,
        .float32x2,
        .float32x4,
    };

    pub const Position = extern struct {
        x: f32,
        y: f32
    };

    pub const UV = extern struct {
        u: f32,
        v: f32
    };

    pub const Color = extern struct {
        red: f32,
        blue: f32,
        green: f32,
        alpha: f32
    };

    position: Position,
    uv: UV,
    color: Color,
};

pub const Index = u16;

const Self = @This();


vertex_buffer: *webgpu.buffer.Buffer,
index_buffer: *webgpu.buffer.Buffer,
vertex_count: u32,


pub fn destroy(self: Self) void {

    self.vertex_buffer.destroy();
    self.vertex_buffer.release();
    self.index_buffer.destroy();
    self.index_buffer.release();
}
