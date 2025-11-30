const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const json = std.json;
const zigimg = @import("zigimg");
const log = std.log.scoped(.gltf_loader);

const Model = @import("Model.zig");

const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

pub const Error = error {
    FilePathInvalid,
    InvalidElementType,
    InvalidElementValue,
    InvalidElementLength,
    InvalidAccessorType,
    RequiredKeyMissing
};

const Self = @This();


allocator: Allocator,

pub fn init(allocator: Allocator) Self {
    return .{ .allocator = allocator };
}

pub fn load(self: Self, directory: fs.Dir, file_name: []const u8) !Model {
    
    var arena = ArenaAllocator.init(self.allocator);

    var file = try directory.openFile(file_name, .{});
    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(&read_buffer);
    const data = try reader.interface.allocRemaining(self.allocator, .unlimited);
    defer self.allocator.free(data);

    const parsed = try json.parseFromSlice(json.Value, self.allocator, data, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();

    return switch (parsed.value) {
        .object => |object| return mapModel(&arena, object, directory),
        else => Error.InvalidElementType
    };
}

fn mapModel(arena: *ArenaAllocator, source: json.ObjectMap, root: fs.Dir) !Model {

    const allocator = arena.allocator();

    const samplers = try mapSamplers(allocator, source.get("samplers"));
    const buffers = try loadBuffers(allocator, source.get("buffers"), root);
    const buffer_views = try mapBufferViews(allocator, source.get("bufferViews"), buffers);
    const images = try loadImages(allocator, source.get("images"), root, buffer_views);
    const accessors = try mapAccessors(allocator, source.get("accessors"), buffer_views);
    _ = images;
    const materials = try mapMaterials(allocator, source.get("materials"));
    const meshes = try mapMeshes(allocator, source.get("meshes"), accessors, materials);
    const nodes = try mapNodes(allocator, source.get("nodes"), meshes);
    if(nodes.len > 0) {
        try resolveNodeChildren(allocator, source.get("nodes").?.array, nodes);
    }
    const scenes = try mapScenes(allocator, source.get("scenes"), nodes);

    return .{
        .arena = arena.*,
        .scene = null,
        .scenes = scenes,
        .nodes = nodes,
        .materials = materials,
        .samplers = samplers
    };
}

fn mapScenes(allocator: Allocator, source: ?json.Value, all_nodes: []const Model.Node) ![]Model.Scene {

    if(source) |value| {
        switch(value) {
            .array => |array| {
                const scenes = try allocator.alloc(Model.Scene, array.items.len);
                for(array.items, scenes) |element, *scene| {
                    scene.* = try mapScene(allocator, element, all_nodes);
                }
                return scenes;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Scene, 0);
}

fn mapScene(allocator: Allocator, value: json.Value, all_nodes: []const Model.Node) !Model.Scene {

    switch (value) {
        .object => |object| {

            const name = try copyString(allocator, object.get("name"));
            const nodes = try resolveIndices(allocator, Model.Node, object.get("nodes"), all_nodes);

            return .{
                .name = name,
                .nodes = nodes
            };
        },
        else => return error.InvalidElementType
    }
}

fn mapNodes(allocator: Allocator, source: ?json.Value, meshes: []Model.Mesh) ![]Model.Node {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const nodes = try allocator.alloc(Model.Node, array.items.len);
                for(array.items, nodes) |element, *node| {
                    node.* = try mapNode(allocator, element, meshes);
                }
                return nodes;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Node, 0);
}

fn mapNode(allocator: Allocator, value: json.Value, meshes: []Model.Mesh) !Model.Node {

    switch (value) {
        .object => |object| {

            const name = try copyString(allocator, object.get("name"));
            const transform = try mapTransform(object.get("matrix"), object.get("translation"), object.get("rotation"), object.get("scale"));
            const mesh = try resolveIndexOptional(Model.Mesh, object.get("mesh"), meshes);

            return .{
                .name = name,
                .children = undefined,
                .mesh = mesh,
                .transform = transform
            };
        },
        else => return Error.InvalidElementType
    }
}

fn mapTransform(matrix_source: ?json.Value, translation_source: ?json.Value, rotation_source: ?json.Value, scale_source: ?json.Value) !Model.Transform {

    if(matrix_source) |value| {
        switch (value) {
            .array => |array| {

                if(array.items.len != 16) return Error.InvalidElementLength;
                
                var values: [16]f32 = undefined;
                for(array.items, values[0..]) |item, *element| {
                    switch (item) {
                        .float => |f| element.* = @floatCast(f),
                        else => return Error.InvalidElementType
                    }
                }
                return Model.Transform {
                    .matrix = values
                };
            },
            else => return Error.InvalidElementType
        }
    }

    const translation = try mapTranslation(translation_source);
    const rotation = try mapRotation(rotation_source);
    const scale = try mapScale(scale_source);

    return Model.Transform {
        .components = .{
            .translation = translation,
            .rotation = rotation,
            .scale = scale
        }
    };
}

fn mapTranslation(source: ?json.Value) ![3]f32 {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                if(array.items.len != 3) return Error.InvalidElementLength;
                var values: [3]f32 = undefined;
                for(array.items, values[0..]) |item, *element| {
                    switch (item) {
                        .float => |f| element.* = @floatCast(f),
                        .integer => |i| element.* = @floatFromInt(i),
                        else => return Error.InvalidElementType
                    }
                }
                return values;
            },
            else => return Error.InvalidElementType
        }
    } else return [3]f32 { 0, 0, 0 };
}

fn mapRotation(source: ?json.Value) ![4]f32 {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                if(array.items.len != 4) return Error.InvalidElementLength;
                var values: [4]f32 = undefined;
                for(array.items, values[0..]) |item, *element| {
                    switch (item) {
                        .float => |f| element.* = @floatCast(f),
                        .integer => |i| element.* = @floatFromInt(i),
                        else => return Error.InvalidElementType
                    }
                }
                return values;
            },
            else => return Error.InvalidElementType
        }
    } else return [4]f32 { 0, 0, 0, 1 };
}

fn mapScale(source: ?json.Value) ![3]f32 {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                if(array.items.len != 3) return Error.InvalidElementLength;
                var values: [3]f32 = undefined;
                for(array.items, values[0..]) |item, *element| {
                    switch (item) {
                        .float => |f| element.* = @floatCast(f),
                        .integer => |i| element.* = @floatFromInt(i),
                        else => return Error.InvalidElementType
                    }
                }
                return values;
            },
            else => return Error.InvalidElementType
        }
    } else return [3]f32 { 1, 1, 1 };
}

fn loadBuffers(allocator: Allocator, source: ?json.Value, root: fs.Dir) ![]const Model.Buffer {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const buffers = try allocator.alloc(Model.Buffer, array.items.len);
                for(array.items, buffers) |item, *buffer| {
                    buffer.* = try loadBuffer(allocator, item, root);
                }
                return buffers;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Buffer, 0);
}

fn loadBuffer(allocator: Allocator, source: json.Value, root: fs.Dir) !Model.Buffer {

    switch (source) {
        .object => |object| {
            if(object.get("uri")) |uri| {
                switch (uri) {
                    .string => |uri_string| {
                        const byte_length = try mapUnsigned(object.get("byteLength")) orelse return Error.RequiredKeyMissing;
                        var file = try root.openFile(uri_string, .{});
                        defer file.close();

                        var read_buffer: [1024]u8 = undefined;
                        var reader = file.reader(&read_buffer);
                        const buffer = try allocator.alloc(u8, @intCast(byte_length));
                        try reader.interface.readSliceAll(buffer);
                        return @alignCast(buffer);
                    },
                    else => return Error.InvalidElementType
                }
            } else return Error.RequiredKeyMissing;
        },
        else => return Error.InvalidElementType
    }
}

fn loadImages(allocator: Allocator, source: ?json.Value, root: fs.Dir, buffer_views: []const Model.BufferView) ![]const Model.Image {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const images = try allocator.alloc(Model.Image, array.items.len);
                for(array.items, images) |item, *buffer| {
                    buffer.* = try loadImage(allocator, item, root, buffer_views);
                }
                return images;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Image, 0);
}

fn loadImage(allocator: Allocator, source: json.Value, root: fs.Dir, buffer_views: []const Model.BufferView) !Model.Image {

    switch (source) {
        .object => |object| {
            const name = try copyString(allocator, object.get("name"));
            
            if(object.get("uri")) |uri| {
                switch (uri) {
                    .string => |uri_string| {

                        var file = try root.openFile(uri_string, .{});
                        defer file.close();

                        var read_buffer: [1024]u8 = undefined;
                        const loaded = try zigimg.Image.fromFile(allocator, file, &read_buffer);
                        const data = loaded.pixels.asConstBytes();

                        return .{
                            .name = name,
                            .data = data
                        };
                    },
                    else => return Error.InvalidElementType
                }
            } else if(try resolveIndexOptional(Model.BufferView, object.get("bufferView"), buffer_views)) |buffer_view| {
                const data = buffer_view.data;
                return .{
                    .name = name,
                    .data = data
                };
            } else return Error.RequiredKeyMissing;
        },
        else => return Error.InvalidElementType
    }
}

fn mapBufferViews(allocator: Allocator, source: ?json.Value, buffers: []const Model.Buffer) ![]Model.BufferView {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const buffer_views = try allocator.alloc(Model.BufferView, array.items.len);
                for(array.items, buffer_views) |item, *buffer_view| {
                    buffer_view.* = try mapBufferView(item, buffers);
                }
                return buffer_views;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.BufferView, 0);
}

fn mapBufferView(source: json.Value, buffers: []const Model.Buffer) !Model.BufferView {

    switch (source) {
        .object => |object| {
            
            const buffer = try resolveIndexOptional(Model.Buffer, object.get("buffer"), buffers) orelse return Error.RequiredKeyMissing;
            const offset = try mapUnsigned(object.get("byteOffset")) orelse 0;
            const length = try mapUnsigned(object.get("byteLength")) orelse return Error.RequiredKeyMissing;
            const target = try mapBufferViewTarget(object.get("target"));
            const stride = try mapByteStride(object.get("byteStride"));
            const data: Model.AlignedData = @alignCast(buffer.*[offset..offset + length]);

            return .{
                .data = data,
                .target = target,
                .stride = stride
            };
        },
        else => return Error.InvalidElementType
    }
}

fn mapBufferViewTarget(source: ?json.Value) !?Model.BufferView.Target {

    if(source) |value| {
        switch (value) {
            .integer => |i| {
                return switch (i) {
                    34962 => Model.BufferView.Target.attribute,
                    34963 => Model.BufferView.Target.index,
                    else => Error.InvalidElementValue
                };
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapByteStride(source: ?json.Value) !?u8 {

    if(source) |value| {
        switch (value) {
            .integer => |i| {
                if(i < 4 or i > 252) return Error.InvalidElementValue;
                return @intCast(i);
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapAccessors(allocator: Allocator, source: ?json.Value, buffer_views: []const Model.BufferView) ![]Model.Accessor {
    
    if(source) |value| {
        switch (value) {
            .array => |array| {
                const accessors = try allocator.alloc(Model.Accessor, array.items.len);
                for(array.items, accessors) |item, *accessor| {
                    accessor.* = try mapAccessor(item, buffer_views);
                }
                return accessors;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Accessor, 0);
}

// TODO sparse accessors
fn mapAccessor(source: json.Value, buffer_views: []const Model.BufferView) !Model.Accessor {

    switch (source) {
        .object => |object| {

            // not required according to spec, but currently by this implementation
            const buffer_view = try resolveIndexOptional(Model.BufferView, object.get("bufferView"), buffer_views) orelse return Error.RequiredKeyMissing;
            const accessor_type = try mapAccessorType(object.get("type")) orelse return Error.RequiredKeyMissing;
            const component_type = try mapComponentType(object.get("componentType")) orelse return Error.RequiredKeyMissing;
            const offset = try mapUnsigned(object.get("byteOffset")) orelse 0;
            const data: Model.AlignedData = @alignCast(buffer_view.data[offset..]);

            return .{
                .component_type = component_type,
                .type = accessor_type,
                .data = data
            };
        },
        else => return Error.InvalidElementType
    }
}

fn mapAccessorType(source: ?json.Value) !?Model.Accessor.Type {

    const mapping = std.StaticStringMap(Model.Accessor.Type).initComptime(.{
        .{ "SCALAR", .scalar },
        .{ "VEC2", .vec2 },
        .{ "VEC3", .vec3 },
        .{ "VEC4", .vec4 },
        .{ "MAT2", .mat2 },
        .{ "MAT3", .mat3 },
        .{ "MAT4", .mat4 },
    });

    if(source) |value| {
        switch (value) {
            .string => |string| {
                const mapped = mapping.get(string);
                return mapped orelse Error.InvalidElementValue;
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapComponentType(source: ?json.Value) !?Model.Accessor.ComponentType {

    if(source) |value| {
        switch (value) {
            .integer => |i| {
                return switch (i) {
                    5120 => .signed_byte,
                    5121 => .unsigned_byte,
                    5122 => .signed_short,
                    5123 => .unsigned_short,
                    5125 => .unsigned_int,
                    5126 => .float,
                    else => Error.InvalidElementValue
                };
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapMeshes(allocator: Allocator, source: ?json.Value, accessors: []const Model.Accessor, materials: []const Model.Material) ![]Model.Mesh {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const meshes = try allocator.alloc(Model.Mesh, array.items.len);
                for(array.items, meshes) |item, *mesh| {
                    mesh.* = try mapMesh(allocator, item, accessors, materials);
                }
                return meshes;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Mesh, 0);
}

fn mapMesh(allocator: Allocator, source: json.Value, accessors: []const Model.Accessor, materials: []const Model.Material) !Model.Mesh {

    switch (source) {
        .object => |object| {
            const name = try copyString(allocator, object.get("name"));
            const primitives = try mapPrimitives(allocator, object.get("primitives"), accessors, materials)
                orelse return Error.RequiredKeyMissing;
            
            return .{
                .name = name,
                .primitives = primitives
            };
        },
        else => return Error.InvalidElementType
    }
}

fn mapPrimitives(allocator: Allocator, source: ?json.Value, accessors: []const Model.Accessor, materials: []const Model.Material) !?[]Model.Primitive {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const primitives = try allocator.alloc(Model.Primitive, array.items.len);
                for(array.items, primitives) |item, *primitive| {
                    primitive.* = try mapPrimitive(item, accessors, materials);
                }
                return primitives;
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapPrimitive(source: json.Value, accessors: []const Model.Accessor, materials: []const Model.Material) !Model.Primitive {

    switch (source) {
        .object => |object| {

            const mode = try mapPrimitiveMode(object.get("mode")) orelse .triangles;
            const attributes = try mapPrimitiveAttributes(object.get("attributes"), accessors)
                orelse return Error.RequiredKeyMissing;
            const indices = try mapIndices(object.get("indices"), accessors);
            const material = try resolveIndexOptional(Model.Material, object.get("material"), materials);

            return .{
                .mode = mode,
                .attributes = attributes,
                .material = material,
                .indices = indices
            };
        },
        else => return Error.InvalidElementType
    }
}

fn mapPrimitiveMode(source: ?json.Value) !?Model.Primitive.Mode {

    if(source) |value| {
        switch (value) {
            .integer => |i| {
                return std.enums.fromInt(Model.Primitive.Mode, i);
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapPrimitiveAttributes(source: ?json.Value, accessors: []const Model.Accessor) !?Model.Primitive.Attributes {

    if(source) |value| {
        switch (value) {
            .object => |object| {
                const positions = try mapPositions(object.get("POSITION"), accessors);
                const normals = try mapNormals(object.get("NORMAL"), accessors);
                // TODO TEXCOORD_n
                const texture_coordinates_0 = try mapTextureCoordinates(object.get("TEXCOORD_0"), accessors);
                return .{
                    .positions = positions,
                    .normals = normals,
                    .texture_coordinates = texture_coordinates_0
                };
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapIndices(source: ?json.Value, accessors: []const Model.Accessor) !?Model.Primitive.Indices {

    const accessor = try resolveIndexOptional(Model.Accessor, source, accessors) orelse return null;
    return switch(accessor.component_type) {
       .unsigned_byte => return Model.Primitive.Indices { .unsigned_byte = @ptrCast(accessor.data) },
       .unsigned_short => return Model.Primitive.Indices { .unsigned_short = @ptrCast(accessor.data) },
       .unsigned_int => return Model.Primitive.Indices { .unsigned_int = @ptrCast(accessor.data) },
       else => Error.InvalidElementValue 
    };
}

// TODO coordinate system remapping
fn mapPositions(source: ?json.Value, accessors: []const Model.Accessor) !?Model.Primitive.Attributes.Positions {

    if(source) |value| {
        const accessor = try resolveIndex(Model.Accessor, value, accessors);
        if(accessor.type == .vec3 and accessor.component_type == .float) {
            return @ptrCast(accessor.data);
        } else {
            return Error.InvalidAccessorType;
        }
    } else return null;

}

fn mapNormals(source: ?json.Value, accessors: []const Model.Accessor) !?Model.Primitive.Attributes.Normals {

    if(source) |value| {
        const accessor = try resolveIndex(Model.Accessor, value, accessors);
        if(accessor.type == .vec3 and accessor.component_type == .float) {
            return @ptrCast(accessor.data);
        } else {
            return Error.InvalidAccessorType;
        }
    } else return null;
}

fn mapTextureCoordinates(source: ?json.Value, accessors: []const Model.Accessor) !?Model.Primitive.Attributes.TextureCoordinates {

    if(source) |value| {
        const accessor = try resolveIndex(Model.Accessor, value, accessors);
        if(accessor.type == .vec2) {
            return switch (accessor.component_type) {
                .float => Model.Primitive.Attributes.TextureCoordinates { .float = @ptrCast(accessor.data) },
                .signed_byte => Model.Primitive.Attributes.TextureCoordinates { .signed_byte_normalized = @ptrCast(accessor.data) },
                .signed_short => Model.Primitive.Attributes.TextureCoordinates { .signed_short_normalized = @ptrCast(accessor.data) },
                .unsigned_byte => Model.Primitive.Attributes.TextureCoordinates { .unsigned_byte_normalized = @ptrCast(accessor.data) },
                .unsigned_short => Model.Primitive.Attributes.TextureCoordinates { .unsigned_short_normalized = @ptrCast(accessor.data) },
                else => Error.InvalidElementValue
            };
        } else {
            return Error.InvalidAccessorType;
        }
    } else return null;
}

fn resolveNodeChildren(allocator: Allocator, source: json.Array, nodes: []Model.Node) !void {

    for(source.items, nodes) |element, *node| {
        node.children = try resolveIndices(allocator, Model.Node, element.object.get("children"), nodes);
    }
}

fn mapMaterials(allocator: Allocator, source: ?json.Value) ![]const Model.Material {
    
    if(source) |value| {
        switch (value) {
            .array => |array| {
                const materials = try allocator.alloc(Model.Material, array.items.len);
                for(array.items, materials) |item, *material| {
                    material.* = try mapMaterial(allocator, item);
                }
                return materials;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Material, 0);
}

fn mapMaterial(allocator: Allocator, source: json.Value) !Model.Material {
     
     switch (source) {
        .object => |object| {

            const name = try copyString(allocator, object.get("name"));
            const double_sided = false;
            const metallic_roughness = try mapMetallicRoughness(object.get("pbrMetallicRoughness"));

            return .{
                .name = name,
                .double_sided = double_sided,
                .metallic_roughness = metallic_roughness
            };
        },
        else => return Error.InvalidAccessorType
     }
}

fn mapMetallicRoughness(source: ?json.Value) !?Model.Material.MetallicRoughness {

    if(source) |value| {
        switch (value) {
            .object => |object| {
                const base_color_factor = try mapColor(object.get("baseColorFactor"));
                return .{
                    .base_color_factor = base_color_factor
                };
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapColor(source: ?json.Value) !?Model.Color {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                if(array.items.len != 4) return Error.InvalidElementLength;
                var color: Model.Color = undefined;
                for(array.items, &color) |item, *element| {
                    switch (item) {
                        .float => |f| element.* = @floatCast(f),
                        .integer => |i| element.* = @floatFromInt(i),
                        else => return Error.InvalidElementType
                    }
                }
                return color;
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapSamplers(allocator: Allocator, source: ?json.Value) ![]const Model.Sampler {
    
    if(source) |value| {
        switch (value) {
            .array => |array| {
                const samplers = try allocator.alloc(Model.Sampler, array.items.len);
                for(array.items, samplers) |item, *material| {
                    material.* = try mapSampler(allocator, item);
                }
                return samplers;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Sampler, 0);
}

fn mapSampler(allocator: Allocator, source: json.Value) !Model.Sampler {

    switch (source) {
        .object => |object| {
            
            const name = try copyString(allocator, object.get("name"));
            const mag_filter = try mapMagFilter(object.get("magFilter"));
            const min_filter = try mapMinFilter(object.get("minFilter"));
            const wrap_u = try mapWrap(object.get("wrapS")) orelse .repeat;
            const wrap_v = try mapWrap(object.get("wrapT")) orelse .repeat;
            
            return .{
                .name = name,
                .mag_filter = mag_filter,
                .min_filter = min_filter,
                .wrap_u = wrap_u,
                .wrap_v = wrap_v
            };
        },
        else => return Error.InvalidElementType
    }
}

fn mapMagFilter(source: ?json.Value) !?Model.Sampler.MagFilter {

    if(source) |value| {
        switch (value) {
            .integer => |i| {
                return switch (i) {
                    9728 => .nearest,
                    9729 => .linear,
                    else => Error.InvalidElementValue
                };
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapMinFilter(source: ?json.Value) !?Model.Sampler.MinFilter {

    if(source) |value| {
        switch (value) {
            .integer => |i| {
                return switch (i) {
                    9728 => .nearest,
                    9729 => .linear,
                    9984 => .nearest_mipmap_nearest,
                    9985 => .linear_mipmap_nearest,
                    9986 => .nearest_mipmap_linear,
                    9987 => .linear_mipmap_linear,
                    else => Error.InvalidElementValue
                };
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapWrap(source: ?json.Value) !?Model.Sampler.Wrap {

    if(source) |value| {
        switch (value) {
            .integer => |i| {
                return switch (i) {
                    33071 => .clamp_to_edge,
                    33648 => .mirrored_repeat,
                    10497 => .repeat,
                    else => Error.InvalidElementValue
                };
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn resolveIndices(allocator: Allocator, T: type, source: ?json.Value, elements: []const T) ![]*const T {

    if(source) |indices| {
        switch (indices) {
            .array => |array| {
                const resolved = try allocator.alloc(*const T, array.items.len);
                for(array.items, resolved) |index_value, *target| {
                    target.* = try resolveIndex(T, index_value, elements);
                }
                return resolved;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(*const T, 0);
}


fn resolveIndex(T: type, source: json.Value, elements: []const T) !*const T {

    switch (source) {
        .integer => |i| {
            if(i < 0 or i >= elements.len) return Error.InvalidElementValue;
            return &elements[@intCast(i)];
        },
        else => return Error.InvalidElementType
    }
}

fn resolveIndexOptional(T: type, source: ?json.Value, elements: []const T) !?*const T {
    return if(source) |value| try resolveIndex(T, value, elements) else null;
}

fn mapUnsigned(source: ?json.Value) !?usize {

    if(source) |value| {
        switch (value) {
            .integer => |i| {
                if(i < 0) return Error.InvalidElementValue;
                return @intCast(i);
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn copyString(allocator: Allocator, source: ?json.Value) !?[]const u8 {

    if(source) |value| {
        return switch (value) {
            .string => |string| try allocator.dupe(u8, string),
            else => Error.InvalidElementType
        };
    } else return null;
}

