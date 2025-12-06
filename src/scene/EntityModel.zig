const std = @import("std");
const webgpu = @import("webgpu");
const algebra = @import("algebra");
const graphics = @import("graphics");
const module = @import("module");
const log = std.log.scoped(.entity_mesh);

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Map = std.AutoArrayHashMapUnmanaged;
const Buffer = webgpu.buffer.Buffer;
const ImageTexture = graphics.ImageTexture;
const TextureView = webgpu.texture_view.TextureView;
const BufferDescriptor = webgpu.buffer.BufferDescriptor;
const Device = webgpu.device.Device;

const Transform = algebra.Transform(f32);
const Matrix = algebra.Matrix(f32, 4, 4);
const Vector3 = algebra.Vector3(f32);
const Quaternion = algebra.Quaternion(f32);


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
    index_offset: u64,
    index_size: u64,
    index_count: u32,
    transform_offset: u32,
    vertex_offset: u64,
    vertex_size: u64,
};

pub const Material = struct {
    color_texture: ImageTexture,
};

pub const MaterialGroup = struct {
    material: Material,
    primitives: []const Primitive
};

const BufferSlice = struct {
    offset: u64,
    size: u64
};

const Self = @This();


transform: Transform,
material_groups: []const MaterialGroup,
transform_buffer: *Buffer,
vertex_buffer: *Buffer,
index_buffer: *Buffer,

pub fn init(allocator: Allocator, device: *webgpu.device.Device, entity: module.Entity) !?Self {

    var vertices = List(Vertex).empty;
    defer vertices.clearAndFree(allocator);

    var indices = List(Index).empty;
    defer indices.clearAndFree(allocator);

    var transforms = List(Matrix).empty;
    defer transforms.clearAndFree(allocator);

    var material_groups = try groupByMaterial(allocator, device, entity, &vertices, &indices, &transforms);

    const transform_buffer_descriptor = BufferDescriptor {
        .size = @sizeOf(Matrix) * transforms.items.len,
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const vertex_buffer_descriptor =  BufferDescriptor {
        .size = vertices.items.len * @sizeOf(Vertex),
        .usage = .{ .vertex = true, .copy_dst = true }
    };

    const index_buffer_descriptor = BufferDescriptor {
        .size = indices.items.len * @sizeOf(u16),
        .usage = .{ .index = true, .copy_dst = true }
    }; 

    const transform_buffer = device.createBuffer(&transform_buffer_descriptor);
    const vertex_buffer = device.createBuffer(&vertex_buffer_descriptor);
    const index_buffer = device.createBuffer(&index_buffer_descriptor);

    const queue = device.getQueue();
    defer queue.release();

    queue.writeBuffer(transform_buffer, Matrix, transforms.items, 0);
    queue.writeBuffer(vertex_buffer, Vertex, vertices.items, 0);
    queue.writeBuffer(index_buffer, u16, indices.items, 0);

    
    // entity.model.materials
    log.debug("entity vertices: {}", .{ vertices.items.len });


    return .{
        .transform = .origin,
        .transform_buffer = transform_buffer,
        .index_buffer = index_buffer,
        .vertex_buffer = vertex_buffer,
        .material_groups = try material_groups.toOwnedSlice(allocator)
    };
}

fn groupByMaterial(allocator: Allocator, device: *Device, entity: module.Entity, vertices: *List(Vertex), indices: *List(Index), transforms: *List(Matrix)) !List(MaterialGroup) {

    var groups = try List(MaterialGroup).initCapacity(allocator, entity.model.materials.len);
    for(entity.model.materials) |*source| {
        
        const material = createMaterial(device, source);
        const primitives = try collectMaterialPrimitives(allocator, source, entity.node, vertices, indices, transforms);
        const group = MaterialGroup {
            .material = material,
            .primitives = primitives
        };
        groups.appendAssumeCapacity(group);
    }
    return groups;
}

fn createMaterial(device: *Device, source: *const module.Entity.Model.Material) Material {
    
    const queue = device.getQueue();
    defer queue.release();

    var material: Material = undefined;

    // TODO handle missing textures
    if(source.metallic_roughness) |metallic_roughness| {
        if(metallic_roughness.base_color_texture) |texture_source| {
            const image = texture_source.image;
            const texture = ImageTexture.create(device, @intCast(image.width), @intCast(image.height), .{ .format = .rgba8_unorm });
            texture.write(queue, image.data);
            material.color_texture = texture;
        }
    }

    return material;
}

fn collectMaterialPrimitives(allocator: Allocator, material: *const module.Entity.Model.Material, node: *const module.Entity.Model.Node,
    vertices: *List(Vertex), indices: *List(Index), transforms: *List(Matrix)) ![]const Primitive {

    var primitives = try List(Primitive).initCapacity(allocator, 32);
    try resolveMaterialPrimitives(allocator, &primitives, material, node, .identity, vertices, indices, transforms);
    return try primitives.toOwnedSlice(allocator);
}

fn resolveMaterialPrimitives(allocator: Allocator, list: *List(Primitive), material: *const module.Entity.Model.Material,
    node: *const module.Entity.Model.Node, parent_transform: Matrix,
    vertices: *List(Vertex), indices: *List(Index), transforms: *List(Matrix)) !void {
    
    const transform = mapTransformMatrix(node.transform);
    const resolved_transform = parent_transform.multiply(transform);

    if(node.mesh) |mesh| {
        for(mesh.primitives) |primitive| {
            const vertex_slice = try appendPrimitiveVertices(allocator, primitive, vertices);
            const index_slice = try appendPrimitiveIndices(allocator, primitive, indices);
            const transform_offset = transforms.items.len * @sizeOf(Matrix);
            const mapped = Primitive {
                .transform_offset = @intCast(transform_offset),
                .vertex_offset = vertex_slice.offset,
                .vertex_size = vertex_slice.size,
                .index_offset = index_slice.offset,
                .index_size = index_slice.size,
                .index_count = @intCast(index_slice.size / @sizeOf(Index))
            };
            try list.append(allocator, mapped);
        }
    }

    for(node.children) |child| {
        try resolveMaterialPrimitives(allocator, list, material, child, resolved_transform, vertices, indices, transforms);
    }
}

fn appendPrimitiveVertices(allocator: Allocator, primitive: module.Entity.Model.Primitive, vertex_list: *List(Vertex)) !BufferSlice {
    
    const offset = vertex_list.items.len;
    const positions = primitive.attributes.positions orelse return error.PositionsMissing;
    const uvs = if(primitive.attributes.texture_coordinates) |uvs| try mapTextureCoordinates(uvs) else return error.TextureCoordinatesMissing;

    try vertex_list.ensureUnusedCapacity(allocator, positions.len);
    
    for(positions, uvs) |position, uv| {
        const vertex = Vertex {
            .position = @bitCast(position),
            .uv = @bitCast(uv)
        };
        vertex_list.appendAssumeCapacity(vertex);
    }

    return .{
        .offset = offset * @sizeOf(Vertex),
        .size = positions.len * @sizeOf(Vertex)
    };
}

fn appendPrimitiveIndices(allocator: Allocator, primitive: module.Entity.Model.Primitive, index_list: *List(Index)) !BufferSlice {
    
    const offset = index_list.items.len;
    const indices = if(primitive.indices) |indices| try mapPrimitiveIndices(indices) else return error.IndicesMissing;    

    try index_list.appendSlice(allocator, indices);
    
    return .{
        .offset = offset * @sizeOf(Index),
        .size = indices.len * @sizeOf(Index)
    };
}

fn mapPrimitiveIndices(indices: module.Entity.Model.Primitive.Indices) ![]const Index {

    switch (indices) {
        .unsigned_short => |values| return @ptrCast(values),
        else => return error.IndexFormatUnsupported
    }
}

fn mapTextureCoordinates(uvs: module.Entity.Model.Primitive.Attributes.TextureCoordinates) ![]const Vertex.UV {

    switch (uvs) {
        .float => |values| return @ptrCast(values),
        else => return error.TextureCoordinateFormatUnsupported
    }
}

// find all children of the node we actually want to render and their children
fn listDescendantNodes(allocator: Allocator, entity: *const module.Entity) ![]const module.Entity.Model.Node {

    var list = try List(module.Entity.Model.Node).initCapacity(allocator, entity.model.nodes.len);
    appendDescendants(entity.node, list);
    return try list.toOwnedSlice(allocator);
}

fn appendDescendants(root: *const module.Entity.Model.Node, list: *List(*const module.Entity.Model.Node)) void {
    
    list.appendSliceAssumeCapacity(root);
    for(root.children) |child| {
        list.appendAssumeCapacity(child);
        appendDescendants(child, list);
    }
}

fn collectMeshTransforms(allocator: Allocator, entity: module.Entity) !List(Matrix) {

    var list = try List(Matrix).initCapacity(allocator, entity.model.nodes.len);
    resolveMeshTransforms(entity.node, .identity, &list);
    return list;
}

fn resolveMeshTransforms(node: *const module.Entity.Model.Node, parent_transform: Matrix, list: *List(Matrix)) void {

    const transform = parent_transform.multiply(mapTransformMatrix(node.transform));
    
    if(node.mesh) {
        list.appendAssumeCapacity(transform);
    }

    for(node.children) |child| {
        resolveMeshTransforms(child, transform, list);
    }
}


fn mapTransformMatrix(source: module.Entity.Model.Transform) Matrix {
    
    switch (source) {
        .matrix => |values| return Matrix.of(values),
        .components => |components| {
            const position = Vector3 {
                .x = components.translation[0],
                .y = components.translation[1],
                .z = components.translation[2]
            };
            const rotation = Quaternion {
                .x = components.rotation[0],
                .y = components.rotation[1],
                .z = components.rotation[2],
                .w = components.rotation[3],
            };
            const scale = Vector3 {
                .x = components.scale[0],
                .y = components.scale[1],
                .z = components.scale[2],
            };
            const transform = Transform {
                .position = position,
                .rotation = rotation,
                .scale = scale
            };
            return transform.toMatrix();
        }
    }
}


pub fn deinit(self: Self) void {
    
    self.transform_buffer.destroy();
    self.vertex_buffer.destroy();
    self.vertex_buffer.release();

    self.transform_buffer.release();
    self.index_buffer.destroy();
    self.index_buffer.release();
}
