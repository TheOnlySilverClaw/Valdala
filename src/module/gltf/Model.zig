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
        pub const Normals = []const [2]f32;
        pub const Texcoords = []const union(enum) {
            float: [][2]f32,
            unorm8: [][2]u8,
            unorm16: [][2]u16
        };

        position: ?Positions,
        normal: ?Normals,
        texcoords: []const Texcoords,
    };

    mode: Mode,
    attributes: Attributes,
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
        mat4,

        pub fn size(self: Type) u32 {
            return switch (self) {
                .scalar => 1,
                
            };
        }
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

scene: ?*const Scene,
scenes: []const Scene,
nodes: []const Node,
materials: []const Material,
samplers: []const Sampler