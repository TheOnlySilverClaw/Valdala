const std = @import("std");
const webgpu = @import("webgpu");

const Self = @This();

pub const Vertex = extern struct {

    pub const format = [_]webgpu.render_pipeline.VertexFormat{
        .float32x3,
        .float16x2,
        .float32x3,
        .uint32
    };

    pub const Position = extern struct {
        x: f32,
        y: f32,
        z: f32
    };

    pub const UV = extern struct {
        /// horizontal offset: left = 0.0 right = 1.0
        u: f16,
        /// vertical offset: top = 0.0 bottom = 1.0
        v: f16,
    };

    pub const Normal = extern struct {
        x: f32,
        y: f32,
        z: f32,
    };

    pub const Texture = u32;


    position: Position,
    uv: UV,
    normal: Normal = .{.x = 0.0, .y = 0.0, .z = 0.0},
    texture: Texture,

};

pub const Index = u32;


vertex_buffer: *webgpu.buffer.Buffer,
index_buffer: *webgpu.buffer.Buffer,

pub fn destroy(self: Self) void {
    
    self.vertex_buffer.destroy();
    self.vertex_buffer.release();

    self.index_buffer.destroy();
    self.index_buffer.release();
}
