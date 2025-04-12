const std = @import("std");
const math = std.math;

pub const Position = extern struct {
    x: f32,
    y: f32,
    z: f32
};

pub const Vertex = extern struct {
    position: Position,
    texture: extern struct {
        u: f16,
        v: f16,
    }
};

pub const Index = u16;


pub const Mesh = struct {
    
    pub const vertex_count = 6 * 2 + 4 * (6 - 1);
    pub const index_count = (4 * 3) * 2 + (2 * 3) * 6;
    pub const size: f32 = 0.25;
    // radius of inner points
    pub const inner: f32 =  size * @cos(math.degreesToRadians(30.0));
    
    vertices: [vertex_count]Vertex,
    indices: [index_count]Index,

    pub fn gridPosition(x: usize, y: usize, z: usize) Position {

        const position_y = @as(f32, @floatFromInt(y)) * size * 1.5;
        const odd = y % 2 == 1;
        const offset_x: f32 = if(odd) inner else 0.0;
        const position_x = @as(f32, @floatFromInt(x)) * inner * 2 + offset_x;
        const position_z = @as(f32, @floatFromInt(z)) * size;
        
        return .{
            .x = position_x,
            .y = position_y,
            .z = position_z
        };
    }

    pub fn instance() Mesh {

        const z_top : f32 = size;
        const z_bottom = 0.01;

        const uv_max: f16 = 1.0;
        const uv_center: f16 = 0.5;
        const uv_quarter: f16 = 0.25;
        const uv_inner: f16 = uv_center * @cos(math.degreesToRadians(30.0));

        const vertices = [vertex_count]Vertex {
            // top
            .{ .position = .{ .x = inner, .y = size / 2, .z = z_top }, .texture = .{.u = uv_center + uv_inner, .v = uv_quarter }}, // 0
            .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_center, .v = 0.0 }},
            .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = uv_center - uv_inner, .v = uv_quarter }},
            .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = uv_center - uv_inner, .v = uv_center + uv_quarter }},
            .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_center, .v = uv_max }},
            .{ .position = .{ .x = inner, .y = -size / 2, .z = z_top }, .texture = .{.u = uv_center + uv_inner, .v = uv_center + uv_quarter }},

            // bottom
            .{ .position = .{ .x = inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = uv_center + uv_inner, .v = uv_quarter }}, // 6
            .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_center, .v = 0.0 }},
            .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = uv_center - uv_inner, .v = uv_quarter }},
            .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = uv_center - uv_inner, .v = uv_center + uv_quarter }},
            .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_center, .v = uv_max }},
            .{ .position = .{ .x = inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = uv_center + uv_inner, .v = uv_center + uv_quarter }},

            // sides
            .{ .position = .{ .x = inner, .y = size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max / 4 }}, // 12
            .{ .position = .{ .x = inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max / 4 }},
            .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = 0 }},  
            .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = 0 }},

            .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = 0 }},  // 16
            .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = 0 }},
            .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max / 4 }},
            .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max / 4 }},

            .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max / 4 }}, // 20
            .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max / 4 }},
            .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }},
            .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }},

            .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }}, // 24
            .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }},
            .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max }},
            .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max }},

            .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max }}, // 28
            .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max }},
            .{ .position = .{ .x = inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max - uv_max / 4 }},
            .{ .position = .{ .x = inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max - uv_max / 4 }},
        };

        const indices = [index_count]Index {
            // top
            0, 1, 2,
            0, 2, 3,
            3, 5, 0,
            3, 4, 5,

            // // bottom, opposite winding
            6, 8, 7,
            6, 9, 8,
            9, 6, 11,
            9, 11, 10,

            // // sides
            12, 13, 14,
            15, 14, 13,

            16, 17, 18,
            19, 18, 17,

            20, 21, 22,
            23, 22, 21,

            24, 25, 26,
            27, 26, 25,

            28, 29, 30,
            31, 30, 29,

            30, 31, 12,
            12, 31, 13
        };

        return .{
            .vertices = vertices,
            .indices = indices
        };
    }
};
