const std = @import("std");
const webgpu = @import("webgpu");
const coordinate = @import("coordinate");
const algebra = @import("algebra");
const module = @import("module");
const terrain = @import("terrain");
const log = std.log.scoped(.mesher);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Tile = @import("Tile.zig");
const TilePosition = coordinate.hexagon.Position(i64);
const Vector = algebra.Vector3(f32);
const TileRegistry = module.TileRegistry;
const Chunk = terrain.Chunk;
const Mesh = @import("ChunkMesh.zig");
const Vertex = Mesh.Vertex;
const Index = Mesh.Index;
const Grid = coordinate.hexagon.Grid(i64, f32);

const Visibility = packed struct {
    top: bool,
    bottom: bool,
    north: bool,
    north_east: bool,
    south_east: bool,
    south: bool,
    south_west: bool,
    north_west: bool
};

const Self = @This();


const vertices_per_tile = (2 * 7) + (6 * 4);
const vertices_per_chunk_max = vertices_per_tile * Chunk.layout.volume;
const indices_per_tile = (3 * 6 * 2) + (2 * 3 * 6);
const indices_per_chunk_max = indices_per_tile * Chunk.layout.volume;


vertex_count: u64,
grid: coordinate.hexagon.Grid(i64, f32),
device: *webgpu.device.Device,
tile_registry: TileRegistry,
vertex_list: List(Vertex),
index_list: List(Index),

pub fn init(allocator: Allocator, device: *webgpu.device.Device, grid: Grid, tile_registry: TileRegistry) !Self {

    const vertex_list = try List(Vertex).initCapacity(allocator, vertices_per_chunk_max);
    const index_list = try List(Index).initCapacity(allocator, indices_per_chunk_max);

    return .{
        .vertex_count = 0,
        .device = device,
        .grid = grid,
        .tile_registry = tile_registry,
        .vertex_list = vertex_list,
        .index_list = index_list
    };
}

pub fn deinit(self: *Self, allocator: Allocator) void {
    self.vertex_list.clearAndFree(allocator);
    self.index_list.clearAndFree(allocator);
}

pub fn generate(self: *Self, position: Chunk.Position, chunk: terrain.Chunk) !Mesh {

    var timer = try std.time.Timer.start();

    const device = self.device;
    const queue = device.getQueue();
    defer queue.release();

    const grid = self.grid;
    var vertex_list = self.vertex_list;
    var index_list = self.index_list;

    const world_position = TilePosition {
        .north = position.north * Chunk.layout.width,
        .south_east = position.south_east * Chunk.layout.width,
        .height = position.height * Chunk.layout.height
    };

    const chunk_start = grid.getCenter(world_position);

    for (0..Chunk.layout.width) |north| {
        for (0..Chunk.layout.width) |south_east| {
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

                const tile_textures = self.tile_registry.getTile(tile.index).textures;
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

                    const north_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north + 1),
                        .south_east = @intCast(south_east),
                        .height = @intCast(height)
                    };
                    
                    const north_neighbor_tile = chunk.getTile(north_neighbor_offset);


                    const north_east_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north + 1),
                        .south_east = @intCast(south_east + 1),
                        .height = @intCast(height)
                    };
                    
                    const north_east_neighbor_tile = chunk.getTile(north_east_neighbor_offset);

                    const south_east_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north),
                        .south_east = @intCast(south_east + 1),
                        .height = @intCast(height)
                    };
                    
                    const south_east_neighbor_tile = chunk.getTile(south_east_neighbor_offset);


                    const south_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north - 1),
                        .south_east = @intCast(south_east),
                        .height = @intCast(height)
                    };
                    
                    const south_neighbor_tile = chunk.getTile(south_neighbor_offset);

                    const south_west_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north - 1),
                        .south_east = @intCast(south_east - 1),
                        .height = @intCast(height)
                    };
                    
                    const south_west_neighbor_tile = chunk.getTile(south_west_neighbor_offset);


                    const north_west_neighbor_offset = Chunk.TileOffset {
                        .north = @intCast(north),
                        .south_east = @intCast(south_east - 1),
                        .height = @intCast(height)
                    };
                    
                    const north_west_neighbor_tile = chunk.getTile(north_west_neighbor_offset);

                    const visibility = Visibility {
                        .top = top_neighbor_tile.index == 0,
                        .bottom = bottom_neighbor_tile.index == 0,
                        .north = north_neighbor_tile.index == 0,
                        .north_east = north_east_neighbor_tile.index == 0,
                        .south_east = south_east_neighbor_tile.index == 0,
                        .south = south_neighbor_tile.index == 0,
                        .south_west = south_west_neighbor_tile.index == 0,
                        .north_west = north_west_neighbor_tile.index == 0
                    };

                    generateTileVertices( grid.hexagon, center, tile_textures, visibility, &vertex_list, &index_list);

                } else {
                    // TODO handle chunk borders better
                    const visibility = Visibility {
                        .top = true,
                        .bottom = true,
                        .north = true,
                        .north_east = true,
                        .south_east = true,
                        .south = true,
                        .south_west = true,
                        .north_west = true
                    };

                    generateTileVertices( grid.hexagon, center, tile_textures, visibility, &vertex_list, &index_list);
                }
            }
        }
    }

    // TODO find smallest valid sizes (with some extra space for remeshing)?
    const vertex_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = vertices_per_chunk_max * @sizeOf(Vertex),
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const index_buffer_descriptor = webgpu.buffer.BufferDescriptor {
        .size = indices_per_chunk_max * @sizeOf(Index),
        .usage = .{ .index = true, .copy_dst = true }
    };

    const vertex_buffer = device.createBuffer(&vertex_buffer_descriptor);
    const index_buffer = device.createBuffer(&index_buffer_descriptor);

    queue.writeBuffer(vertex_buffer, Vertex, vertex_list.items, 0);
    queue.writeBuffer(index_buffer, Index, index_list.items, 0);

    self.vertex_count += vertex_list.items.len;
    log.debug("meshed chunk at {f} with vertex count: {} in {} ms", .{position, vertex_list.items.len, timer.read() / std.time.ns_per_ms });

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

    const vert_ne_top_north = Vertex { .position = pos_ne_top, .uv = uv_top_left, .texture = texture_side };
    const vert_ne_bottom_north = Vertex { .position = pos_ne_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_nw_top_north = Vertex { .position = pos_nw_top, .uv = uv_top_right, .texture = texture_side };
    const vert_nw_bottom_north = Vertex { .position = pos_nw_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_e_top_north_east = Vertex { .position = pos_e_top, .uv = uv_top_left, .texture = texture_side };
    const vert_e_bottom_north_east = Vertex { .position = pos_e_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_ne_top_north_east = Vertex { .position = pos_ne_top, .uv = uv_top_right, .texture = texture_side };
    const vert_ne_bottom_north_east = Vertex { .position = pos_ne_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_se_top_south_east = Vertex { .position = pos_se_top, .uv = uv_top_left, .texture = texture_side };
    const vert_se_bottom_south_east = Vertex { .position = pos_se_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_e_top_south_east = Vertex { .position = pos_e_top, .uv = uv_top_right, .texture = texture_side };
    const vert_e_bottom_south_east = Vertex { .position = pos_e_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_sw_top_south = Vertex { .position = pos_sw_top, .uv = uv_top_left, .texture = texture_side };
    const vert_sw_bottom_south = Vertex { .position = pos_sw_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_se_top_south = Vertex { .position = pos_se_top, .uv = uv_top_right, .texture = texture_side };
    const vert_se_bottom_south = Vertex { .position = pos_se_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_w_top_south_west = Vertex { .position = pos_w_top, .uv = uv_top_left, .texture = texture_side };
    const vert_w_bottom_south_west = Vertex { .position = pos_w_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_sw_top_south_west = Vertex { .position = pos_sw_top, .uv = uv_top_right, .texture = texture_side };
    const vert_sw_bottom_south_west = Vertex { .position = pos_sw_bottom, .uv = uv_bottom_right, .texture = texture_side };

    const vert_nw_top_north_west = Vertex { .position = pos_nw_top, .uv = uv_top_left, .texture = texture_side };
    const vert_nw_bottom_north_west = Vertex { .position = pos_nw_bottom, .uv = uv_bottom_left, .texture = texture_side };
    const vert_w_top_north_west = Vertex { .position = pos_w_top, .uv = uv_top_right, .texture = texture_side };
    const vert_w_bottom_north_west = Vertex { .position = pos_w_bottom, .uv = uv_bottom_right, .texture = texture_side };

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

    if(visibility.north) {
        const vertices = [_]Vertex {
            vert_ne_top_north,
            vert_ne_bottom_north,
            vert_nw_top_north,
            vert_nw_bottom_north,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.north_east) {
        const vertices = [_]Vertex {
            vert_e_top_north_east,
            vert_e_bottom_north_east,
            vert_ne_top_north_east,
            vert_ne_bottom_north_east,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.south_east) {
        const vertices = [_]Vertex {
            vert_se_top_south_east,
            vert_se_bottom_south_east,
            vert_e_top_south_east,
            vert_e_bottom_south_east,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.south) {
        const vertices = [_]Vertex {
            vert_sw_top_south,
            vert_sw_bottom_south,
            vert_se_top_south,
            vert_se_bottom_south,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.south_west) {
        const vertices = [_]Vertex {
            vert_w_top_south_west,
            vert_w_bottom_south_west,
            vert_sw_top_south_west,
            vert_sw_bottom_south_west,
        };
        appendSquareIndices(@intCast(vertex_list.items.len), index_list);
        vertex_list.appendSliceAssumeCapacity(&vertices);
    }

    if(visibility.north_west) {
        const vertices = [_]Vertex {
            vert_nw_top_north_west,
            vert_nw_bottom_north_west,
            vert_w_top_north_west,
            vert_w_bottom_north_west,
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