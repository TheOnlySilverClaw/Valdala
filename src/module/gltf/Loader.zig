const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const json = std.json;
const log = std.log.scoped(.gltf_loader);

const Model = @import("Model.zig");

const Allocator = std.mem.Allocator;

pub const Error = error {
    FilePathInvalid,
    InvalidElementType,
    InvalidElementValue,
    InvalidElementLength,
    RequiredKeyMissing
};

const Self = @This();


allocator: Allocator,

pub fn init(allocator: Allocator) Self {
    return .{ .allocator = allocator };
}

pub fn load(self: Self, directory: fs.Dir, file_name: []const u8) !Model {
    
    var file = try directory.openFile(file_name, .{});
    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var reader = file.reader(&read_buffer);
    const data = try reader.interface.allocRemaining(self.allocator, .unlimited);
    defer self.allocator.free(data);

    const parsed = try json.parseFromSlice(json.Value, self.allocator, data, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();

    return switch (parsed.value) {
        .object => |object| return mapModel(self.allocator, object, directory),
        else => Error.InvalidElementType
    };
}

fn mapModel(allocator: Allocator, source: json.ObjectMap, root: fs.Dir) !Model {

    const nodes = try mapNodes(allocator, source.get("nodes"));
    if(nodes.len > 0) {
        try resolveNodeChildren(allocator, source.get("nodes").?.array, nodes);
    }
    const buffers = try loadBuffers(allocator, source.get("buffers"), root);
    const buffer_views = try mapBufferViews(allocator, source.get("bufferViews"), buffers);
    const accessors = try mapAccessors(allocator, source.get("accessors"), buffer_views);
    const meshes = try mapMeshes(allocator, source.get("meshes"));
    const scenes = try mapScenes(allocator, source.get("scenes"), nodes);
    _ = accessors;
    log.debug("count {}", .{ meshes.len });

    return .{
        .scene = null,
        .scenes = scenes,
        .nodes = nodes
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

fn mapNodes(allocator: Allocator, source: ?json.Value) ![]Model.Node {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const nodes = try allocator.alloc(Model.Node, array.items.len);
                for(array.items, nodes) |element, *node| {
                    node.* = try mapNode(allocator, element);
                }
                return nodes;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Node, 0);
}

fn mapNode(allocator: Allocator, value: json.Value) !Model.Node {

    switch (value) {
        .object => |object| {

            const name = try copyString(allocator, object.get("name"));
            const transform = try mapTransform(object.get("matrix"), object.get("translation"), object.get("rotation"), object.get("scale"));

            return .{
                .name = name,
                .children = undefined,
                .mesh = null,
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
                        if(object.get("byteLength")) |byte_length_value| {
                            switch (byte_length_value) {
                                .integer => |byte_length| {
                                    
                                    if(byte_length < 0) return Error.InvalidElementType;
                                    
                                    var file = try root.openFile(uri_string, .{});
                                    defer file.close();

                                    var read_buffer: [1024]u8 = undefined;
                                    var reader = file.reader(&read_buffer);
                                    const buffer = try allocator.alloc(u8, @intCast(byte_length));
                                    try reader.interface.readSliceAll(buffer);
                                    return buffer;
                                },
                                else => return Error.InvalidElementType
                            }
                        } else return Error.RequiredKeyMissing;
                    },
                    else => return Error.InvalidElementType
                }
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
            
            const index = try mapUnsigned(object.get("buffer")) orelse return Error.RequiredKeyMissing;
            const offset = try mapUnsigned(object.get("byteOffset")) orelse 0;
            const length = try mapUnsigned(object.get("byteLength")) orelse return Error.RequiredKeyMissing;
            const target = try mapBufferViewTarget(object.get("target"));
            const stride = try mapByteStride(object.get("byteStride"));
            const buffer = buffers[index];

            return .{
                .buffer = buffer[offset..offset + length],
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
            const index = try mapUnsigned(object.get("bufferView")) orelse return Error.RequiredKeyMissing;
            const accessor_type = try mapAccessorType(object.get("type")) orelse return Error.RequiredKeyMissing;
            const component_type = try mapComponentType(object.get("componentType")) orelse return Error.RequiredKeyMissing;
            const offset = try mapUnsigned(object.get("byteOffset")) orelse 0;
            const buffer_view = buffer_views[index];
            const bytes = buffer_view.buffer[offset..];

            return .{
                .component_type = component_type,
                .type = accessor_type,
                .bytes = bytes
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

fn mapMeshes(allocator: Allocator, source: ?json.Value) ![]Model.Mesh {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const meshes = try allocator.alloc(Model.Mesh, array.items.len);
                for(array.items, meshes) |item, *mesh| {
                    mesh.* = try mapMesh(allocator, item);
                }
                return meshes;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(Model.Mesh, 0);
}

fn mapMesh(allocator: Allocator, source: json.Value) !Model.Mesh {

    switch (source) {
        .object => |object| {
            const name = try copyString(allocator, object.get("name"));
            const primitives = try mapPrimitives(allocator, object.get("primitives")) orelse return Error.RequiredKeyMissing;
            return .{
                .name = name,
                .primitives = primitives
            };
        },
        else => return Error.InvalidElementType
    }
}

fn mapPrimitives(allocator: Allocator, source: ?json.Value) !?[]Model.Mesh.Primitives {

    if(source) |value| {
        switch (value) {
            .array => |array| {
                const primitives = try allocator.alloc(Model.Mesh.Primitives, array.items.len);
                for(array.items, primitives) |item, *primitive| {
                    primitive.* = try mapPrimitive(allocator, item);
                }
                return primitives;
            },
            else => return Error.InvalidElementType
        }
    } else return null;
}

fn mapPrimitive(allocator: Allocator, source: json.Value) !Model.Mesh.Primitives {
    _ = allocator;
    _ = source;
    return undefined;
}

fn resolveNodeChildren(allocator: Allocator, source: json.Array, nodes: []Model.Node) !void {

    for(source.items, nodes) |element, *node| {
        node.children = try resolveIndices(allocator, Model.Node, element.object.get("children"), nodes);
    }
}

fn resolveIndices(allocator: Allocator, T: type, source: ?json.Value, elements: []const T) ![]*const T {

    if(source) |indices| {
        switch (indices) {
            .array => |array| {
                const resolved = try allocator.alloc(*const T, array.items.len);
                for(array.items, resolved) |index_value, *target| {
                    switch (index_value) {
                        .integer => |i| {
                            if(i >= 0) {
                                const index: usize = @intCast(i);
                                const ptr = &elements[index];
                                target.* = ptr;
                            } else return Error.InvalidElementType;
                        },
                        else => return Error.InvalidElementType
                    }
                }
                return resolved;
            },
            else => return Error.InvalidElementType
        }
    } else return try allocator.alloc(*const T, 0);
}

fn copyString(allocator: Allocator, source: ?json.Value) ![]const u8 {

    if(source) |value| {
        return switch (value) {
            .string => |string| try allocator.dupe(u8, string),
            else => Error.InvalidElementType
        };
    } else return "";
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