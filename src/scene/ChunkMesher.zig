const std = @import("std");
const webgpu = @import("webgpu");
const coordinate = @import("coordinate");
const algebra = @import("algebra");
const module = @import("module");
const world = @import("world");
const log = std.log.scoped(.mesher);

const Allocator = std.mem.Allocator;
const Tile = @import("Tile.zig");
const TilePosition = coordinate.hexagon.Position(i64);
const Vector = algebra.Vector3(f32);
const TileRegistry = module.TileRegistry;
const Chunk = world.Chunk;
const Mesh = @import("ChunkMesh.zig");
const Vertex = Mesh.Vertex;
const Index = Mesh.Index;
const List = std.ArrayListUnmanaged;

const Self = @This();


const vertices_per_tile = (2 * 7) + (6 * 4);
const vertices_per_chunk_max = vertices_per_tile * Chunk.layout.volume;
const indices_per_chunk_max = base_indices.len * Chunk.layout.volume;

const base_indices = [_]Mesh.Index {
    // top
    1, 0, 2,
    2, 0, 3,
    3, 0, 4,
    4, 0, 5,
    5, 0, 6,
    6, 0, 1,

    // bottom
    7, 8, 9,
    7, 9, 10,
    7, 10, 11,
    7, 11, 12,
    7, 12, 13,
    7, 13, 8,

    // side 1
    14, 15, 16,
    17, 16, 15,

    // side 2
    18, 19, 20,
    21, 20, 19,

    // side 3
    22, 23, 24,
    25, 24, 23,

    // side 4
    26, 27, 28,
    29, 28, 27,

    // side 5
    30, 31, 32,
    33, 32, 31,

    // side 6
    34, 35, 36,
    37, 36, 35
};

vertex_count: u64 = 0,
grid: coordinate.hexagon.Grid(i64, f32),
device: *webgpu.Device,
tile_registry: TileRegistry,


pub fn generate(self: *Self, allocator: Allocator, position: Chunk.Position, chunk: world.Chunk) !Mesh {

    const device = self.device;
    const queue = device.getQueue();
    defer queue.release();

    const grid = self.grid;

    const world_position = TilePosition {
        .north = position.north * Chunk.layout.width,
        .south_east = position.south_east * Chunk.layout.width,
        .height = position.height * Chunk.layout.height
    };

    const chunk_start = grid.getCenter(world_position);

    // TODO reuse memory?
    var vertex_list = try List(Vertex).initCapacity(allocator, vertices_per_chunk_max);
    defer vertex_list.clearAndFree(allocator);
    var index_list = try List(Index).initCapacity(allocator, indices_per_chunk_max);
    defer index_list.clearAndFree(allocator);

    const width = Chunk.layout.width;

    var tile_counter: u32 = 0;

    for (0..width) |north| {
        for (0..width) |south_east| {
            for(0..Chunk.layout.height) |height| {
            const tile_offset = Chunk.TileOffset {
                .north = @intCast(north),
                .south_east = @intCast(south_east),
                .height = @intCast(height)
            };
            const tile_position = TilePosition {
                .north = @intCast(north),
                .south_east = @intCast(south_east),
                .height = @intCast(height)
            };

            const tile = chunk.getTile(tile_offset);
            // don't render air blocks
            if(tile.index == 0) continue;

            const tile_textures = self.tile_registry.tiles.items[tile.index - 1].textures;
            const center = grid.getCenter(tile_position).add(chunk_start);
            
            const vertices = generateTileVertices( grid.hexagon, center, tile_textures);
            vertex_list.appendSliceAssumeCapacity(&vertices);

            for(base_indices) |base_index| {
                const index: Index = @intCast(tile_counter * vertices.len + base_index);
                index_list.appendAssumeCapacity(index);
            }

            tile_counter += 1;
            }
        }
    }

    // TODO find smallest valid sizes (with some extra space for remeshing)?
    const vertex_buffer_descriptor = webgpu.BufferDescriptor {
        .size = vertices_per_chunk_max * @sizeOf(Vertex),
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const index_buffer_descriptor = webgpu.BufferDescriptor {
        .size = indices_per_chunk_max * @sizeOf(Index),
        .usage = .{ .index = true, .copy_dst = true }
    };

    const vertex_buffer = device.createBuffer(&vertex_buffer_descriptor);
    const index_buffer = device.createBuffer(&index_buffer_descriptor);

    queue.writeBuffer(vertex_buffer, Vertex, vertex_list.items, 0);
    queue.writeBuffer(index_buffer, Index, index_list.items, 0);

    self.vertex_count += vertex_list.items.len;
    log.debug("vertex count: {}", .{ self.vertex_count });

    return .{
        .vertex_buffer = vertex_buffer,
        .index_buffer = index_buffer
    };
}


fn generateTileVertices(hex: coordinate.hexagon.Hexagon(f32), center: Vector, textures: module.Tile.Textures) [vertices_per_tile]Vertex {
    
    const texture_top: Vertex.Texture = textures.top;
    const texture_side: Vertex.Texture = textures.side;
    const texture_bottom: Vertex.Texture = textures.bottom;

    const z_top = center.z + hex.height;
    const z_bottom = center.z;

    const half_side = hex.side / 2;

    const pos_center_top = Vertex.Position { .x = center.x, .y = center.y, .z = z_top };
    const pos_nw_top = Vertex.Position { .x = center.x - half_side, .y = center.y + hex.inradius, .z = z_top };
    const pos_ne_top = Vertex.Position { .x = center.x + half_side, .y = center.y + hex.inradius, .z = z_top };
    const pos_e_top = Vertex.Position { .x = center.x + hex.circumradius, .y = center.y, .z = z_top };
    const pos_se_top = Vertex.Position { .x = center.x + half_side, .y = center.y - hex.inradius, .z = z_top };
    const pos_sw_top = Vertex.Position { .x = center.x - half_side, .y = center.y - hex.inradius, .z = z_top };
    const pos_w_top = Vertex.Position { .x = center.x - hex.circumradius, .y = center.y, .z = z_top };

    const pos_center_bottom = Vertex.Position { .x = center.x, .y = center.y, .z = z_bottom };
    const pos_nw_bottom = Vertex.Position { .x = center.x - half_side, .y = center.y + hex.inradius, .z = z_bottom };
    const pos_ne_bottom = Vertex.Position { .x = center.x + half_side, .y = center.y + hex.inradius, .z = z_bottom };
    const pos_e_bottom = Vertex.Position { .x = center.x + hex.circumradius, .y = center.y, .z = z_bottom };
    const pos_se_bottom = Vertex.Position { .x = center.x + half_side, .y = center.y - hex.inradius, .z = z_bottom };
    const pos_sw_bottom = Vertex.Position { .x = center.x - half_side, .y = center.y - hex.inradius, .z = z_bottom };
    const pos_w_bottom = Vertex.Position { .x = center.x - hex.circumradius, .y = center.y, .z = z_bottom };

    
    const uv_top_left = Vertex.UV { .u = 0, .v = 0 };
    const uv_top_right = Vertex.UV { .u = 1, .v = 0 };
    const uv_bottom_left = Vertex.UV { .u = 0, .v = 1 };
    const uv_bottom_right = Vertex.UV { .u = 1, .v = 1 };
    const uv_bottom_center = Vertex.UV { .u = 0.5, .v = 1 };

    const ver_center_top = Vertex { .position = pos_center_top, .uv = uv_bottom_center, .texture = texture_top };
    const vert_nw_top = Vertex { .position = pos_nw_top, .uv = uv_top_left, .texture = texture_top };
    const vert_ne_top = Vertex { .position = pos_ne_top, .uv = uv_top_right, .texture = texture_top };
    const vert_e_top = Vertex { .position = pos_e_top, .uv = uv_top_left, .texture = texture_top };
    const vert_se_top = Vertex { .position = pos_se_top, .uv = uv_top_right, .texture = texture_top };
    const vert_sw_top = Vertex { .position = pos_sw_top, .uv = uv_top_left, .texture = texture_top };
    const vert_w_top = Vertex { .position = pos_w_top, .uv = uv_top_right, .texture = texture_top };

    const ver_center_bottom = Vertex { .position = pos_center_bottom, .uv = uv_bottom_center, .texture = texture_bottom };
    const vert_nw_bottom = Vertex { .position = pos_nw_bottom, .uv = uv_top_left, .texture = texture_bottom };
    const vert_ne_bottom = Vertex { .position = pos_ne_bottom, .uv = uv_top_right, .texture = texture_bottom };
    const vert_e_bottom = Vertex { .position = pos_e_bottom, .uv = uv_top_left, .texture = texture_bottom };
    const vert_se_bottom = Vertex { .position = pos_se_bottom, .uv = uv_top_right, .texture = texture_bottom };
    const vert_sw_bottom = Vertex { .position = pos_sw_bottom, .uv = uv_top_left, .texture = texture_bottom };
    const vert_w_bottom = Vertex { .position = pos_w_bottom, .uv = uv_top_right, .texture = texture_bottom };

    const vert_ne_top_side1 = Vertex { .position = pos_ne_top, .uv = uv_top_left, .texture = texture_side };
    const vert_ne_bottom_side1 = Vertex { .position = pos_ne_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_nw_top_side1 = Vertex { .position = pos_nw_top, .uv = uv_top_right, .texture = texture_side };
    const vert_nw_bottom_side1 = Vertex { .position = pos_nw_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_e_top_side2 = Vertex { .position = pos_e_top, .uv = uv_top_left, .texture = texture_side };
    const vert_e_bottom_side2 = Vertex { .position = pos_e_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_ne_top_side2 = Vertex { .position = pos_ne_top, .uv = uv_top_right, .texture = texture_side };
    const vert_ne_bottom_side2 = Vertex { .position = pos_ne_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_se_top_side3 = Vertex { .position = pos_se_top, .uv = uv_top_left, .texture = texture_side };
    const vert_se_bottom_side3 = Vertex { .position = pos_se_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_e_top_side3 = Vertex { .position = pos_e_top, .uv = uv_top_right, .texture = texture_side };
    const vert_e_bottom_side3 = Vertex { .position = pos_e_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_sw_top_side4 = Vertex { .position = pos_sw_top, .uv = uv_top_left, .texture = texture_side };
    const vert_sw_bottom_side4 = Vertex { .position = pos_sw_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_se_top_side4 = Vertex { .position = pos_se_top, .uv = uv_top_right, .texture = texture_side };
    const vert_se_bottom_side4 = Vertex { .position = pos_se_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_w_top_side5 = Vertex { .position = pos_w_top, .uv = uv_top_left, .texture = texture_side };
    const vert_w_bottom_side5 = Vertex { .position = pos_w_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_sw_top_side5 = Vertex { .position = pos_sw_top, .uv = uv_top_right, .texture = texture_side };
    const vert_sw_bottom_side5 = Vertex { .position = pos_sw_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_nw_top_side6 = Vertex { .position = pos_nw_top, .uv = uv_top_left, .texture = texture_side };
    const vert_nw_bottom_side6 = Vertex { .position = pos_nw_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_w_top_side6 = Vertex { .position = pos_w_top, .uv = uv_top_right, .texture = texture_side };
    const vert_w_bottom_side6 = Vertex { .position = pos_w_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vertices = [_]Vertex {
        ver_center_top,
        vert_nw_top,
        vert_ne_top,
        vert_e_top,
        vert_se_top,
        vert_sw_top,
        vert_w_top,
        
        ver_center_bottom,
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
