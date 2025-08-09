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

pub const Index = u32;

const hex = coordinate.Hexagon(f32).new(0.5 * 1, 0.5);
const grid = coordinate.Grid(i64, f32).of(hex);
const vertices_per_tile = (2 * 6) + (4 * 6);

vertex_buffer: *webgpu.Buffer,
index_buffer: *webgpu.Buffer,

pub fn generate(chunk: *const Chunk, device: *webgpu.Device) Self {

    const vertex_buffer_descriptor = webgpu.BufferDescriptor {
        .size = Chunk.Layout.volume * vertices_per_tile * @sizeOf(Vertex),
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const base_indices = [_]Index {
        // top
        0, 4, 1,
        1, 4, 3,
        0, 5, 4,
        1, 3, 2,

        // bottom
        7, 10, 6,
        9, 10, 7,
        10, 11, 6,
        8, 9, 7,

        // side 1
        12, 13, 14,
        15, 14, 13,

        // side 2
        16, 17, 18,
        19, 18, 17,

        // side 3
        20, 21, 22,
        23, 22, 21,

        // side 4
        24, 25, 26,
        27, 26, 25,

        // side 5
        28, 29, 30,
        31, 30, 29,

        // side 6
        32, 33, 34,
        35, 34, 33
    };

    const index_buffer_descriptor = webgpu.BufferDescriptor {
        .size = Chunk.Layout.volume * base_indices.len * @sizeOf(Index),
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

    for (0..width) |north| {
        for (0..width) |south_east| {
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
            var indices: [base_indices.len]Index = undefined;
            for(base_indices, 0..) |base_index, index_number| {
                indices[index_number] = @intCast(tile_index * vertices.len + base_index);
            }

            queue.writeBuffer(vertex_buffer, Vertex, &vertices, tile_index * vertices.len * @sizeOf(Vertex));
            queue.writeBuffer(index_buffer, Index, &indices, tile_index * indices.len * @sizeOf(Index));

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

pub fn generateTileVertices(tile: Tile, center: Vector, odd: bool) [vertices_per_tile]Vertex {
    
    const texture_top: Vertex.Texture = tile.index * 4;

    const z_top = center.z + hex.height;
    const z_bottom = center.z;

    const half_side = hex.side / 2;

    const pos_nw_top = Vertex.Position { .x = center.x - half_side, .y = center.y + hex.inradius, .z = z_top };
    const pos_ne_top = Vertex.Position { .x = center.x + half_side, .y = center.y + hex.inradius, .z = z_top };
    const pos_e_top = Vertex.Position { .x = center.x + hex.circumradius, .y = center.y, .z = z_top };
    const pos_se_top = Vertex.Position { .x = center.x + half_side, .y = center.y - hex.inradius, .z = z_top };
    const pos_sw_top = Vertex.Position { .x = center.x - half_side, .y = center.y - hex.inradius, .z = z_top };
    const pos_w_top = Vertex.Position { .x = center.x - hex.circumradius, .y = center.y, .z = z_top };

    const pos_nw_bottom = Vertex.Position { .x = center.x - half_side, .y = center.y + hex.inradius, .z = z_bottom };
    const pos_ne_bottom = Vertex.Position { .x = center.x + half_side, .y = center.y + hex.inradius, .z = z_bottom };
    const pos_e_bottom = Vertex.Position { .x = center.x + hex.circumradius, .y = center.y, .z = z_bottom };
    const pos_se_bottom = Vertex.Position { .x = center.x + half_side, .y = center.y - hex.inradius, .z = z_bottom };
    const pos_sw_bottom = Vertex.Position { .x = center.x - half_side, .y = center.y - hex.inradius, .z = z_bottom };
    const pos_w_bottom = Vertex.Position { .x = center.x - hex.circumradius, .y = center.y, .z = z_bottom };

    const uv_off: f16 = if(odd) 0.0 else 1.0;
    const uv_top_left = Vertex.UV { .u = uv_off, .v = uv_off };
    const uv_top_right = Vertex.UV { .u = 2.0 + uv_off, .v = uv_off };
    const uv_bottom_left = Vertex.UV { .u = uv_off, .v = 2.0 + uv_off };
    const uv_bottom_right = Vertex.UV { .u = 2.0 + uv_off, .v = 2.0 + uv_off };
    const uv_center = Vertex.UV { .u = 1.0 + uv_off, .v = 1.0 + uv_off };

    const vert_nw_top = Vertex { .position = pos_nw_top, .uv = uv_top_left, .texture = texture_top };
    const vert_ne_top = Vertex { .position = pos_ne_top, .uv = uv_top_right, .texture = texture_top };
    const vert_e_top = Vertex { .position = pos_e_top, .uv = uv_center, .texture = texture_top };
    const vert_se_top = Vertex { .position = pos_se_top, .uv = uv_bottom_right, .texture = texture_top };
    const vert_sw_top = Vertex { .position = pos_sw_top, .uv = uv_bottom_left, .texture = texture_top };
    const vert_w_top = Vertex { .position = pos_w_top, .uv = uv_center, .texture = texture_top };

    const vert_nw_bottom = Vertex { .position = pos_nw_bottom, .uv = uv_top_left, .texture = texture_top };
    const vert_ne_bottom = Vertex { .position = pos_ne_bottom, .uv = uv_top_right, .texture = texture_top };
    const vert_e_bottom = Vertex { .position = pos_e_bottom, .uv = uv_center, .texture = texture_top };
    const vert_se_bottom = Vertex { .position = pos_se_bottom, .uv = uv_bottom_right, .texture = texture_top };
    const vert_sw_bottom = Vertex { .position = pos_sw_bottom, .uv = uv_bottom_left, .texture = texture_top };
    const vert_w_bottom = Vertex { .position = pos_w_bottom, .uv = uv_center, .texture = texture_top };

    const vert_ne_top_side1 = Vertex { .position = pos_ne_top, .uv = uv_top_left, .texture = texture_top };
    const vert_ne_bottom_side1 = Vertex { .position = pos_ne_bottom, .uv = uv_bottom_left, .texture = texture_top };
    const vert_nw_top_side1 = Vertex { .position = pos_nw_top, .uv = uv_top_right, .texture = texture_top };
    const vert_nw_bottom_side1 = Vertex { .position = pos_nw_bottom, .uv = uv_bottom_right, .texture = texture_top };

    const vert_e_top_side2 = Vertex { .position = pos_e_top, .uv = uv_top_left, .texture = texture_top };
    const vert_e_bottom_side2 = Vertex { .position = pos_e_bottom, .uv = uv_bottom_left, .texture = texture_top };
    const vert_ne_top_side2 = Vertex { .position = pos_ne_top, .uv = uv_top_right, .texture = texture_top };
    const vert_ne_bottom_side2 = Vertex { .position = pos_ne_bottom, .uv = uv_bottom_right, .texture = texture_top };

    const vert_se_top_side3 = Vertex { .position = pos_se_top, .uv = uv_top_left, .texture = texture_top };
    const vert_se_bottom_side3 = Vertex { .position = pos_se_bottom, .uv = uv_bottom_left, .texture = texture_top };
    const vert_e_top_side3 = Vertex { .position = pos_e_top, .uv = uv_top_right, .texture = texture_top };
    const vert_e_bottom_side3 = Vertex { .position = pos_e_bottom, .uv = uv_bottom_right, .texture = texture_top };

    const vert_sw_top_side4 = Vertex { .position = pos_sw_top, .uv = uv_top_left, .texture = texture_top };
    const vert_sw_bottom_side4 = Vertex { .position = pos_sw_bottom, .uv = uv_bottom_left, .texture = texture_top };
    const vert_se_top_side4 = Vertex { .position = pos_se_top, .uv = uv_top_right, .texture = texture_top };
    const vert_se_bottom_side4 = Vertex { .position = pos_se_bottom, .uv = uv_bottom_right, .texture = texture_top };

    const vert_w_top_side5 = Vertex { .position = pos_w_top, .uv = uv_top_left, .texture = texture_top };
    const vert_w_bottom_side5 = Vertex { .position = pos_w_bottom, .uv = uv_bottom_left, .texture = texture_top };
    const vert_sw_top_side5 = Vertex { .position = pos_sw_top, .uv = uv_top_right, .texture = texture_top };
    const vert_sw_bottom_side5 = Vertex { .position = pos_sw_bottom, .uv = uv_bottom_right, .texture = texture_top };

    const vert_nw_top_side6 = Vertex { .position = pos_nw_top, .uv = uv_top_left, .texture = texture_top };
    const vert_nw_bottom_side6 = Vertex { .position = pos_nw_bottom, .uv = uv_bottom_left, .texture = texture_top };
    const vert_w_top_side6 = Vertex { .position = pos_w_top, .uv = uv_top_right, .texture = texture_top };
    const vert_w_bottom_side6 = Vertex { .position = pos_w_bottom, .uv = uv_bottom_right, .texture = texture_top };

    const vertices = [_]Vertex {
        vert_nw_top,
        vert_ne_top,
        vert_e_top,
        vert_se_top,
        vert_sw_top,
        vert_w_top,
        
        vert_nw_bottom,
        vert_ne_bottom,
        vert_e_bottom,
        vert_se_bottom,
        vert_sw_bottom,
        vert_w_bottom,

        vert_ne_top_side1,
        vert_ne_bottom_side1,
        vert_nw_top_side1,
        vert_nw_bottom_side1,

        vert_e_top_side2,
        vert_e_bottom_side2,
        vert_ne_top_side2,
        vert_ne_bottom_side2,

        vert_se_top_side3,
        vert_se_bottom_side3,
        vert_e_top_side3,
        vert_e_bottom_side3,

        vert_sw_top_side4,
        vert_sw_bottom_side4,
        vert_se_top_side4,
        vert_se_bottom_side4,

        vert_w_top_side5,
        vert_w_bottom_side5,
        vert_sw_top_side5,
        vert_sw_bottom_side5,

        vert_nw_top_side6,
        vert_nw_bottom_side6,
        vert_w_top_side6,
        vert_w_bottom_side6,
    };
    return vertices;
}
