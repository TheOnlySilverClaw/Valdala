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

const hex = coordinate.Hexagon(f32).new(1.0, 0);
const grid = coordinate.Grid(i64, f32).of(hex);

vertex_buffer: *webgpu.Buffer,
index_buffer: *webgpu.Buffer,

pub fn generate(chunk: *const Chunk, device: *webgpu.Device) Self {

    // for (0..Chunk.Layout.width) |north| {
    //     for (0..Chunk.Layout.width) |south_east| {
    //         // TODO height
    //         const tile_offset = Chunk.TileOffset {
    //             .north = @intCast(north),
    //             .south_east = @intCast(south_east),
    //             .height = 0
    //         };
    //         const tile_position = TilePosition {
    //             .north = @intCast(north),
    //             .south_east = @intCast(south_east),
    //             .height = 0
    //         };
    //         const tile = chunk.getTile(tile_offset);
    //         const center = grid.getCenter(tile_position);
    //         generateTileMesh(tile, center);
    //     }
    // }
    _ = chunk;

    const texture_top: Vertex.Texture = 0;

    const uv_top_left = Vertex.UV { .u = 0.0, .v = 0.0 };
    const uv_top_right = Vertex.UV { .u = 1.0, .v = 0.0 };
    const uv_bottom = Vertex.UV { .u = 0.0, .v = 1.0 };

    const pos_center_top = Vertex.Position { .x = 0.0, .y = 0.0, .z = hex.height };
    const pos_n_top = Vertex.Position { .x = 0.0, .y = hex.circumradius, .z = hex.height };
    const pos_ne_top = Vertex.Position { .x = hex.inradius, .y = hex.side / 2, .z = hex.height };
    const pos_se_top = Vertex.Position { .x = hex.inradius, .y = -hex.side / 2, .z = hex.height };
    const pos_s_top = Vertex.Position { .x = 0.0, .y = -hex.circumradius, .z = hex.height };
    const pos_sw_top = Vertex.Position { .x = -hex.inradius, .y = -hex.side / 2, .z = hex.height };
    const pos_nw_top = Vertex.Position { .x = -hex.inradius, .y = hex.side / 2, .z = hex.height };

    const vert_center_top = Vertex { .position = pos_center_top, .uv = uv_bottom, .texture = texture_top };
    const vert_n_top = Vertex { .position = pos_n_top, .uv = uv_top_left, .texture = texture_top };
    const vert_ne_top = Vertex { .position = pos_ne_top, .uv = uv_top_right, .texture = texture_top };
    const vert_se_top = Vertex { .position = pos_se_top, .uv = uv_top_left, .texture = texture_top };
    const vert_s_top = Vertex { .position = pos_s_top, .uv = uv_top_right, .texture = texture_top };
    const vert_sw_top = Vertex { .position = pos_sw_top, .uv = uv_top_left, .texture = texture_top };
    const vert_nw_top = Vertex { .position = pos_nw_top, .uv = uv_top_right, .texture = texture_top };


    const vertices = [_]Vertex {
        vert_center_top,
        vert_n_top,
        vert_ne_top,
        vert_se_top,
        vert_s_top,
        vert_sw_top,
        vert_nw_top
    };

    for(vertices) |v| {
        log.debug("vertex ({d:.2}, {d:.2}, {d:.2})", .{ v.position.x, v.position.y, v.position.z });
    }

    const indices = [_]u16 {
        0, 2, 1,
        0, 3, 2,
        0, 4, 3,
        0, 5, 4,
        0, 6, 5,
        0, 1, 6
    };

    const vertex_buffer_descriptor = webgpu.BufferDescriptor {
        .size = Chunk.Layout.volume * 6 * 4,
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const index_buffer_descriptor = webgpu.BufferDescriptor {
        .size = Chunk.Layout.volume * 4,
        .usage = .{ .index = true, .copy_dst = true }
    };

    const vertex_buffer = device.createBuffer(&vertex_buffer_descriptor);
    const index_buffer = device.createBuffer(&index_buffer_descriptor);

    const queue = device.getQueue();
    defer queue.release();

    queue.writeBuffer(vertex_buffer, Vertex, &vertices, 0);
    queue.writeBuffer(index_buffer, u16, &indices, 0);

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

pub fn generateTileMesh(tile: Tile, center: Vector) void {
    _ = tile;
    _ = center;
    // log.debug("generate mesh {} {}", .{ tile, center});
}
