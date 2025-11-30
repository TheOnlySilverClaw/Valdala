const std = @import("std");
const webgpu = @import("webgpu");
const algebra = @import("algebra");
const graphics = @import("graphics");
const module = @import("module");
const log = std.log.scoped(.entity_mesh);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;

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

// TODO Handle u32 indices? Most meshes at our complexity level seem to use u16 anyway.
pub const Index = u16;


pub const Primitive = struct {
    vertices: []const Vertex
};

const Self = @This();

transform: Transform(f32),
vertex_buffer: *webgpu.buffer.Buffer,
index_buffer: *webgpu.buffer.Buffer,
base_color_buffer: *webgpu.buffer.Buffer,

pub fn init(allocator: Allocator, device: *webgpu.device.Device, entity: module.Entity) !?Self {

    var vertices = List(Vertex).empty;
    defer vertices.clearAndFree(allocator);

    var indices = List(Index).empty;
    defer indices.clearAndFree(allocator);

    try appendNodeMeshes(allocator, entity.node, &vertices, &indices);

    const vertex_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = vertices.items.len * @sizeOf(Vertex),
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const index_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = indices.items.len * @sizeOf(u16),
        .usage = .{ .index = true, .copy_dst = true }
    };

    const base_color_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = 
    }

    const vertex_buffer = device.createBuffer(&vertex_buffer_descriptor);
    const index_buffer = device.createBuffer(&index_buffer_descriptor);

    const queue = device.getQueue();
    defer queue.release();

    queue.writeBuffer(vertex_buffer, Vertex, vertices.items, 0);
    queue.writeBuffer(index_buffer, u16, indices.items, 0);

    log.debug("entity vertices: {}", .{ vertices.items.len });

    return .{
        .transform = .origin,
        .index_buffer = index_buffer,
        .vertex_buffer = vertex_buffer,
    };
}

fn appendNodeMeshes(allocator: Allocator, node: *const module.Entity.Model.Node, vertices: *List(Vertex), indices: *List(Index)) !void {

    if(node.mesh) |mesh| {
        for(mesh.primitives) |primitive| {

            const positions = primitive.attributes.positions orelse return error.PositionsMissing;
            try vertices.ensureUnusedCapacity(allocator, positions.len);

            const uvs = primitive.attributes.texture_coordinates orelse return error.TextureCoordinatesMissing;
            // TODO handle or convert normalized integer formats
            const uv_data = switch(uvs) {
                .float => |f| f,
                else => return error.TextureCoordinatesUnsupported
            };

            for(positions, uv_data) |position, uv| {
                log.debug("uv: {} {}", .{ uv[0], uv[1] });
                const vertex = Vertex {
                    .position = @bitCast(position),
                    .uv = @bitCast(uv)
                };
                vertices.appendAssumeCapacity(vertex);
            }

            const primitive_indices = primitive.indices orelse return error.IndicesMissing;
            const indices_data = switch (primitive_indices) {
                .unsigned_short => |u| u,
                else => return error.UnsupportedIndexFormat
            };
            try indices.appendSlice(allocator, indices_data);
        }
    }

    for(node.children) |child| {
        try appendNodeMeshes(allocator, child, vertices, indices);
    }
}

pub fn deinit(self: Self) void {
    
    self.vertex_buffer.destroy();
    self.vertex_buffer.release();

    self.index_buffer.destroy();
    self.index_buffer.release();
}
