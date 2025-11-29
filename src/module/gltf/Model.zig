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

};

pub const Mesh = struct {

    pub const Primitives = struct {
        attributes: Attributes,
        material: ?Material
    };

    pub const Attributes = struct {
        position: usize,
        normal: usize,
        texcoords: []const usize,
    };

    name: []const u8,
    primitives: []const Primitives
};

pub const Buffer = []const u8;

pub const BufferView = struct {
    
    pub const Target = enum {
        attribute,
        index
    };

    target: ?Target,
    data: []const u8,
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
    
    data: []const u8,
    type: Type,
    component_type: ComponentType

};

scene: ?*const Scene,
scenes: []const Scene,
nodes: []const Node,
materials: []const Material
