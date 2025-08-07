const std = @import("std");
const webgpu = @import("webgpu");
const coordinate = @import("coordinate");
const algebra = @import("algebra");
const log = std.log.scoped(.mesh);

const Chunk = @import("scene").Chunk;
const Tile = @import("scene").Tile;
const TilePosition = coordinate.Position(i64);
const Vector = algebra.Vector3(f32);

const Self = @This();

pub const Vertex = extern struct {
    pub const format = [_]webgpu.VertexFormat{ .float32x3, .float32x2, .uint32 };

    pub const Position = extern struct { x: f32, y: f32, z: f32 };

    pub const UV = extern struct {
        /// horizontal offset: left = 0.0 right = 1.0
        u: f16,
        /// vertical offset: top = 0.0 bottom = 1.0
        v: f16,
    };

    pub const Texture = u32;

    position: Position,
    uv: UV,
    texture: Texture,
};

const hex = coordinate.Hexagon(f32).new(0.5, 0);
const grid = coordinate.Grid(i64, f32).of(hex);

vertex_buffer: *webgpu.Buffer,
index_buffer: *webgpu.Buffer,

pub fn generate(camera: *const @import("scene").Camera, chunk: *const Chunk, device: *webgpu.Device) Self {

    const vertex_buffer_descriptor = webgpu.BufferDescriptor {
        .size = Chunk.Layout.volume * 6 * @sizeOf(Vertex),
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const base_indices = [_]u16 {
        0, 4, 1,
        1, 4, 3,
        0, 5, 4,
        1, 3, 2
    };

    const index_buffer_descriptor = webgpu.BufferDescriptor {
        .size = Chunk.Layout.volume * base_indices.len * @sizeOf(u16),
        .usage = .{ .index = true, .copy_dst = true }
    };

    const vertex_buffer = device.createBuffer(&vertex_buffer_descriptor);
    const index_buffer = device.createBuffer(&index_buffer_descriptor);

    const queue = device.getQueue();
    defer queue.release();

    const width = Chunk.Layout.width;

    var tile_index: u32 = 0;
    const chunk_center = grid.getCenter(.{
        .north = @intCast(width / 2),
        .south_east = @intCast(width / 2),
        .height = 0
    });

    for (32..33) |north| {
        for (32..33) |south_east| {
            // TODO height
            const tile_offset = Chunk.TileOffset {
                .north = @intCast(north),
                .south_east = @intCast(south_east),
                .height = 0
            };
            const tile_position = TilePosition {
                .north = @intCast(north),
                .south_east = @intCast(south_east),
                .height = 0
            };

            const odd = south_east % 2 == 1;

            const tile = chunk.getTile(tile_offset);
            const center = grid.getCenter(tile_position).subtract(chunk_center);
            const vertices = generateTileVertices(tile, center, odd);
            
            const camera_matrix = camera.toMatrix();
            for(vertices, 0..) |v, i| {

                const vm = algebra.Matrix(f32, 1, 4).of(.{ v.position.x, v.position.y, v.position.z, 1 });
                const p = camera_matrix.multiply(vm);
                log.debug("v{} {d:.5} {d:.5} {d:.5}", .{ i, p.values[0], p.values[1], p.values[2] });
            }
            var indices: [base_indices.len]u16 = undefined;
            for(base_indices, 0..) |base_index, index_number| {
                indices[index_number] = @intCast(tile_index * vertices.len + base_index);
            }

            queue.writeBuffer(vertex_buffer, Vertex, &vertices, tile_index * vertices.len * @sizeOf(Vertex));
            queue.writeBuffer(index_buffer, u16, &indices, tile_index * indices.len * @sizeOf(u16));

            tile_index += 1;
        }
    }

    return .{
        .vertex_buffer = vertex_buffer,
        .index_buffer = index_buffer
    };
}

pub fn deinit(self: Self) void {
    
    self.vertex_buffer.destroy();
    self.vertex_buffer.release();

    self.index_buffer.destroy();
    self.index_buffer.release();
}

pub fn generateTileVertices(tile: Tile, center: Vector, odd: bool) [6]Vertex {
    
    const texture_top: Vertex.Texture = tile.index * 4;

    const half_side = hex.side / 2;

    const pos_nw_top = Vertex.Position { .x = center.x - half_side, .y = center.y + hex.inradius, .z = hex.height };
    const pos_ne_top = Vertex.Position { .x = center.x + half_side, .y = center.y + hex.inradius, .z = hex.height };
    const pos_e_top = Vertex.Position { .x = center.x + hex.circumradius, .y = center.y, .z = hex.height };
    const pos_se_top = Vertex.Position { .x = center.x + half_side, .y = center.y - hex.inradius, .z = hex.height };
    const pos_sw_top = Vertex.Position { .x = center.x - half_side, .y = center.y - hex.inradius, .z = hex.height };
    const pos_w_top = Vertex.Position { .x = center.x - hex.circumradius, .y = center.y, .z = hex.height };
    const pos_w_center_top = Vertex.Position { .x = center.x - half_side, .y = center.y, .z = hex.height };
    const pos_e_center_top = Vertex.Position { .x = center.x + half_side, .y = center.y, .z = hex.height };

    const uv_off: f16 = if(odd) 0.0 else 1.0;
    const uv_top_left = Vertex.UV { .u = uv_off, .v = uv_off };
    const uv_top_right = Vertex.UV { .u = 2.0 + uv_off, .v = uv_off };
    const uv_bottom_left = Vertex.UV { .u = uv_off, .v = 2.0 + uv_off };
    const uv_bottom_right = Vertex.UV { .u = 2.0 + uv_off, .v = 2.0 + uv_off };
    const uv_center = Vertex.UV { .u = 1.0 + uv_off, .v = 1.0 + uv_off };
    const uv_center_left = Vertex.UV { .u = uv_off, .v = 1.0 + uv_off };
    const uv_center_right = Vertex.UV { .u = 2.0 + uv_off, .v = 1.0 + uv_off };

    const vert_nw_top = Vertex { .position = pos_nw_top, .uv = uv_top_left, .texture = texture_top };
    const vert_ne_top = Vertex { .position = pos_ne_top, .uv = uv_top_right, .texture = texture_top };
    const vert_e_top = Vertex { .position = pos_e_top, .uv = uv_center, .texture = texture_top };
    const vert_se_top = Vertex { .position = pos_se_top, .uv = uv_bottom_right, .texture = texture_top };
    const vert_sw_top = Vertex { .position = pos_sw_top, .uv = uv_bottom_left, .texture = texture_top };
    const vert_w_top = Vertex { .position = pos_w_top, .uv = uv_center, .texture = texture_top };
    const vert_w_center_top = Vertex { .position = pos_w_center_top, .uv = uv_center_left, .texture = texture_top };
    const vert_e_center_top = Vertex { .position = pos_e_center_top, .uv = uv_center_right, .texture = texture_top };

    _ = vert_se_top;
    _ = vert_sw_top;

    const vertices = [_]Vertex {
        vert_nw_top,
        vert_ne_top,
        vert_e_top,
        vert_e_center_top,
        vert_w_center_top,
        vert_w_top
    };
    return vertices;
}
