const std = @import("std");

pub const Node = struct {
    name: []const u8,
    transform: Transform,
    children: []const *const Node,
    mesh: ?*const Mesh
};

pub const Transform = union(enum) {
    matrix: [16]f32,
    components: struct {
        translation: [3]f32,
        rotation: [4]f32,
        scale: [3]f32
    }
};

pub const Scene = struct {
    name: []const u8,
    nodes: []const *const Node
};

pub const Material = struct {
    name: []const u8,
    double_sided: bool,
    emissive_texture: *const Texture
};

pub const Texture = struct {
    data: AlignedData
};

pub const Sampler = struct {

    pub const MagFilter = enum {
        nearest,
        linear
    };

    pub const MinFilter = enum {
        nearest,
        linear,
        nearest_mipmap_nearest,
        linear_mipmap_nearest,
        nearest_mipmap_linear,
        linear_mipmap_linear
    };

    pub const Wrap = enum {
        clamp_to_edge,
        mirrored_repeat,
        repeat
    };

    name: []const u8,
    mag_filter: ?MagFilter,
    min_filter: ?MinFilter,
    wrap_u: Wrap,
    wrap_v: Wrap
};

pub const Mesh = struct {
    name: []const u8,
    primitives: []const Primitive
};

pub const Primitive = struct {

    pub const Mode = enum {
        points,
        lines,
        line_strip,
        triangles,
        triangle_strip,
        triangle_fan
    };

    pub const Attributes = struct {

        pub const Positions = []const [3]f32;
        
        pub const Normals = []const [3]f32;
        
        pub const TextureCoordinates = union(enum) {
            float: []const [2]f32,
            signed_byte_normalized: []const [2]i8,
            signed_short_normalized: []const [2]i16,
            unsigned_byte_normalized: []const [2]u8,
            unsigned_short_normalized: []const [2]u16,
        };

        positions: ?Positions,
        normals: ?Normals,
        // TODO support multiple texture coordinates
        texture_coordinates: ?TextureCoordinates
    };

    pub const Indices = union(enum) {
        unsigned_byte: []const u8,
        unsigned_short: []const u16,
        unsigned_int: []const u32
    };

    mode: Mode,
    attributes: Attributes,
    indices: ?Indices,
    material: ?*const Material
};

pub const AlignedData = []const align(4) u8;

pub const Buffer = AlignedData;

pub const BufferView = struct {
    
    pub const Target = enum {
        attribute,
        index
    };

    target: ?Target,
    data: AlignedData,
    stride: ?u8
};

pub const Accessor = struct {
    
    pub const Type = enum {
        scalar,
        vec2,
        vec3,
        vec4,
        mat2,
        mat3,
        mat4
    };

    pub const ComponentType = enum {
        signed_byte,
        unsigned_byte,
        signed_short,
        unsigned_short,
        unsigned_int,
        float
    };
    
    data: AlignedData,
    type: Type,
    component_type: ComponentType

};

pub const Image = struct {
    name: []const u8,
    data: []const u8
};

arena: std.heap.ArenaAllocator,
scene: ?*const Scene,
scenes: []const Scene,
nodes: []const Node,
materials: []const Material,
samplers: []const Sampler,

pub fn deinit(self: @This()) void {
    self.arena.deinit();
}