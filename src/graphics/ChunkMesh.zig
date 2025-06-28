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

    pub const Texture = extern struct {
        /// horizontal offset: left = 0.0 right = 1.0
        u: f32,
        /// vertical offset: top = 0.0 bottom = 1.0
        v: f32,
    };

    pub const TextureIndex = u32;

    position: Position,
    texture: Texture,
    texture_index: TextureIndex,
};

const hexagon = coordinate.Hexagon(f32).new(2.5, 2.5);
const grid = coordinate.Grid(i64, f32).of(hexagon);

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

    const vertices = [_]Vertex {
        Vertex { .position = .{ .x = -0.5, .y = 0.5, .z = 0.0 }, .texture = undefined, .texture_index = 0 },
        Vertex { .position = .{ .x = -0.5, .y = -0.5, .z = 0.0 }, .texture = undefined, .texture_index = 0  },
        Vertex { .position = .{ .x = 0.5, .y = 0.5, .z = 0.0 }, .texture = undefined, .texture_index = 0  },
        Vertex { .position = .{ .x = 0.5, .y = 0.5, .z = 0.0 }, .texture = undefined, .texture_index = 0  },
    };

    const indices = [_]u16 {
        0, 1, 2, 3
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
