const std = @import("std");
const webgpu = @import("webgpu");
const algebra = @import("algebra");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const Transform = algebra.Transform;


pub const Vertex = extern struct {

    pub const format = [_]webgpu.render_pipeline.VertexFormat{
        .float32x3,
        .float32x2,
    };

    pub const Position = extern struct {
        x: f32,
        y: f32,
        z: f32
    };

    pub const UV = extern struct {
        /// horizontal offset: left = 0.0 right = 1.0
        u: f32,
        /// vertical offset: top = 0.0 bottom = 1.0
        v: f32,
    };

    position: Position,
    uv: UV,
};

pub const Index = u16;

const Self = @This();

transform: Transform(f32),
vertex_buffer: *webgpu.buffer.Buffer,
index_buffer: *webgpu.buffer.Buffer,
color_texture: ?u32,

pub fn init(allocator: Allocator, device: *webgpu.device.Device, positions: []const f32, uvs: []const f32, indices: []const Index, color_texture: ?u32) !Self {

    const vertices = try createVertices(allocator, positions, uvs);
    defer allocator.free(vertices);

    const vertex_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = vertices.len * @sizeOf(Vertex),
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const index_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = indices.len * @sizeOf(Index),
        .usage = .{ .index = true, .copy_dst = true }
    };

    const vertex_buffer = device.createBuffer(&vertex_buffer_descriptor);
    const index_buffer = device.createBuffer(&index_buffer_descriptor);

    const queue = device.getQueue();
    defer queue.release();

    queue.writeBuffer(vertex_buffer, Vertex, vertices, 0);
    queue.writeBuffer(index_buffer, Index, indices, 0);

    return .{
        .transform = .origin,
        .index_buffer = index_buffer,
        .vertex_buffer = vertex_buffer,
        .color_texture = color_texture
    };
}

pub fn deinit(self: Self) void {
    
    self.vertex_buffer.destroy();
    self.vertex_buffer.release();

    self.index_buffer.destroy();
    self.index_buffer.release();
}

fn createVertices(allocator: Allocator, positions: []const f32, uvs: []const f32) ![]const Vertex {

    const vertices = try allocator.alloc(Vertex, positions.len / 3);
    
    for(vertices, 0..) |*vertex, index| {
        vertex.position.x = positions[index * 3];
        vertex.position.y = positions[index * 3 + 1];
        vertex.position.z = positions[index * 3 + 2];
        vertex.uv.u = uvs[index * 2];
        vertex.uv.v = uvs[index * 2 + 1];
    }

    return vertices;
}
