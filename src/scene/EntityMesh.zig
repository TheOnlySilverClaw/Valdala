const webgpu = @import("webgpu");


pub const Vertex = extern struct {

    pub const format = [_]webgpu.render_pipeline.VertexFormat{
        .float32x3,
        // .float32x2,
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

    position: Position,
    // uv: UV,
};

pub const Index = u16;

const Self = @This();


vertex_buffer: *webgpu.buffer.Buffer,
index_buffer: *webgpu.buffer.Buffer,

pub fn init(device: *webgpu.device.Device, vertices: []const Vertex, indices: []const Index) Self {

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
        .index_buffer = index_buffer,
        .vertex_buffer = vertex_buffer
    };
}

pub fn deinit(self: Self) void {
    
    self.vertex_buffer.destroy();
    self.vertex_buffer.release();

    self.index_buffer.destroy();
    self.index_buffer.release();
}