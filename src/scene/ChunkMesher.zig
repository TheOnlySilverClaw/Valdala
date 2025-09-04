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

const Visibility = struct {
    top: bool,
    bottom: bool,
    sides: [6]bool
};

const Self = @This();


const vertices_per_tile = (2 * 7) + (6 * 4);
const vertices_per_chunk_max = vertices_per_tile * Chunk.layout.volume;
const indices_per_tile = (3 * 6 * 2) + (2 * 3 * 6);
const indices_per_chunk_max = indices_per_tile * Chunk.layout.volume;


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

                if(north > 0 and north < Chunk.layout.width - 1 and south_east > 0 and south_east < Chunk.layout.width - 1 and height > 0 and height < Chunk.layout.height - 1) {
                    
                    const top_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north),
                        .south_east = @intCast(south_east),
                        .height = @intCast(height + 1)
                    };
                    
                    const top_neighbor_tile = chunk.getTile(top_neighbor_offset);

                    const bottom_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north),
                        .south_east = @intCast(south_east),
                        .height = @intCast(height - 1)
                    };
                    
                    const bottom_neighbor_tile = chunk.getTile(bottom_neighbor_offset);

                    const side1_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north + 1),
                        .south_east = @intCast(south_east),
                        .height = @intCast(height)
                    };
                    
                    const side1_neighbor_tile = chunk.getTile(side1_neighbor_offset);


                    const side2_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north + 1),
                        .south_east = @intCast(south_east + 1),
                        .height = @intCast(height)
                    };
                    
                    const side2_neighbor_tile = chunk.getTile(side2_neighbor_offset);

                    const side3_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north),
                        .south_east = @intCast(south_east + 1),
                        .height = @intCast(height)
                    };
                    
                    const side3_neighbor_tile = chunk.getTile(side3_neighbor_offset);


                    const side4_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north - 1),
                        .south_east = @intCast(south_east),
                        .height = @intCast(height)
                    };
                    
                    const side4_neighbor_tile = chunk.getTile(side4_neighbor_offset);

                    const side5_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north - 1),
                        .south_east = @intCast(south_east - 1),
                        .height = @intCast(height)
                    };
                    
                    const side5_neighbor_tile = chunk.getTile(side5_neighbor_offset);


                    const side6_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north),
                        .south_east = @intCast(south_east - 1),
                        .height = @intCast(height)
                    };
                    
                    const side6_neighbor_tile = chunk.getTile(side6_neighbor_offset);

                    const visibility = Visibility {
                        .top = top_neighbor_tile.index == 0,
                        .bottom = bottom_neighbor_tile.index == 0,
                        .sides = .{
                            side1_neighbor_tile.index == 0,
                            side2_neighbor_tile.index == 0,
                            side3_neighbor_tile.index == 0,
                            side4_neighbor_tile.index == 0,
                            side5_neighbor_tile.index == 0,
                            side6_neighbor_tile.index == 0
                        }
                    };

                    generateTileVertices( grid.hexagon, center, tile_textures, visibility, &vertex_list, &index_list);

                } else {
                    // TODO handle chunk borders better
                    const visibility = Visibility {
                        .top = true,
                        .bottom = true,
                        .sides = .{ true } ** 6
                    };

                    generateTileVertices( grid.hexagon, center, tile_textures, visibility, &vertex_list, &index_list);
                }
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


fn generateTileVertices(hex: coordinate.hexagon.Hexagon(f32), center: Vector, textures: module.Tile.Textures, visibility: Visibility, vertex_list: *List(Vertex), index_list: *List(Index)) void {
    
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

    if(visibility.top) {
        const vertices = [_]Vertex {
            ver_center_top,
            vert_nw_top,
            vert_ne_top,
            vert_e_top,
            vert_se_top,
            vert_sw_top,
            vert_w_top,
        };
        appendTopIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.bottom) {
        const vertices = [_]Vertex {
            ver_center_bottom,
            vert_nw_bottom,
            vert_ne_bottom,
            vert_e_bottom,
            vert_se_bottom,
            vert_sw_bottom,
            vert_w_bottom,
        };
        appendBottomIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.sides[0]) {
        const vertices = [_]Vertex {
            vert_ne_top_side1,
            vert_ne_bottom_side1,
            vert_nw_top_side1,
            vert_nw_bottom_side1,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.sides[1]) {
        const vertices = [_]Vertex {
            vert_e_top_side2,
            vert_e_bottom_side2,
            vert_ne_top_side2,
            vert_ne_bottom_side2,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.sides[2]) {
        const vertices = [_]Vertex {
            vert_se_top_side3,
            vert_se_bottom_side3,
            vert_e_top_side3,
            vert_e_bottom_side3,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.sides[3]) {
        const vertices = [_]Vertex {
            vert_sw_top_side4,
            vert_sw_bottom_side4,
            vert_se_top_side4,
            vert_se_bottom_side4,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.sides[4]) {
        const vertices = [_]Vertex {
            vert_w_top_side5,
            vert_w_bottom_side5,
            vert_sw_top_side5,
            vert_sw_bottom_side5,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.sides[5]) {
        const vertices = [_]Vertex {
            vert_nw_top_side6,
            vert_nw_bottom_side6,
            vert_w_top_side6,
            vert_w_bottom_side6,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }
}

fn appendTopIndices(start: Index, list: *List(Index)) void {
    
    const indices = [_]Index {
        start + 1, start, start + 2,
        start + 2, start, start + 3,
        start + 3, start, start + 4,
        start + 4, start, start + 5,
        start + 5, start, start + 6,
        start + 6, start, start + 1
    };
    list.appendSliceAssumeCapacity(&indices);
}

fn appendBottomIndices(start: Index, list: *List(Index)) void {
    
    const indices = [_]Index {
        start, start + 1, start + 2,
        start, start + 2, start + 3,
        start, start + 3, start + 4,
        start, start + 4, start + 5,
        start, start + 5, start + 6,
        start, start + 6, start + 1
    };
    list.appendSliceAssumeCapacity(&indices);
}

fn appendSquareIndices(start: Index, list: *List(Index)) void {
    
    const indices = [_]Index {
        start, start + 1, start + 2,
        start + 3, start + 2, start + 1
    };
    list.appendSliceAssumeCapacity(&indices);
}