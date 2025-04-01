const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;
const webgpu = @import("webgpu");
const Surface = @import("Surface.zig");
const VertexBuffer = @import("VertexBuffer.zig").VertexBuffer;
const PerVertexBuffer = VertexBuffer(Vertex, &.{.float32x3, .unorm16x2 });
const PerInstanceBuffer = VertexBuffer(Instance, &.{ .float32x3, .uint32 });
const VertexLayout = @import("VertexLayout.zig");
const Shader = @import("shader.zig").Shader;
const TextureArray = @import("TextureArray.zig");

const Self = @This();


block_sampler: *webgpu.Sampler,
block_texture: TextureArray,
vertex_buffer: PerVertexBuffer,
instance_buffer: PerInstanceBuffer,
index_buffer: *webgpu.Buffer,
bind_group_layout: *webgpu.BindGroupLayout,
handle: *webgpu.RenderPipeline,


pub fn create(allocator: Allocator, surface: *const Surface) !Self {

    const device = surface.device;

    const block_sampler = createSampler(device, .repeat, .nearest);

    const shader_module = try Shader.loadModule(allocator, device, "shaders/textured.wgsl", "textured");
    const vertex_shader = Shader {
        .entry = webgpu.StringView.sized("vertex"),
        .module =  shader_module
    };
    const fragment_shader = Shader {
        .entry = webgpu.StringView.sized("fragment"),
        .module = shader_module
    };

    var block_texture = TextureArray {
        .label = webgpu.StringView.sized("blocks"),
        .format = surface.colorTextureFormat,
        .width = 16,
        .height = 16,
        .layers = 4
    };
    block_texture.create(device);
    
    try block_texture.loadImageFiles(allocator, surface.queue, &.{
        "textures/testing/texture_1.qoi",
        "textures/testing/texture_2.qoi",
        "textures/testing/texture_3.qoi",
        "textures/testing/texture_4.qoi"
    });

    const uv_max = math.maxInt(u16);
    const size: f32 = 0.5;
    const z_top : f32 = size;
    const z_bottom = 0.01;
    // radius of inner points
    const inner: f32 = @cos(math.degreesToRadians(30.0)) * size;

    const vertices = [_]Vertex {
        // top
        .{ .position = .{ .x = 0, .y = 0, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max / 2 }}, // 0 - M_t
        .{ .position = .{ .x = inner, .y = size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max / 4 }}, // A_t
        .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = 0 }},  
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max / 4 }},
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }},
        .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max }},
        .{ .position = .{ .x = inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max - uv_max / 4 }},

        // bottom
        .{ .position = .{ .x = 0, .y = 0, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max / 2 }}, // 7 - M_b
        .{ .position = .{ .x = inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max / 4 }}, // A_b
        .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = 0 }},  
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max / 4 }},
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }},
        .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max }},
        .{ .position = .{ .x = inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max - uv_max / 4 }},

        // sides
        .{ .position = .{ .x = inner, .y = size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max / 4 }}, // 14
        .{ .position = .{ .x = inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max / 4 }},
        .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = 0 }},  
        .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = 0 }},

        .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = 0 }},  // 18
        .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = 0 }},
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max / 4 }},
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max / 4 }},

        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max / 4 }}, // 22
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max / 4 }},
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }},
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }},

        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }}, // 26
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max - uv_max / 4 }},
        .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max }},
        .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max }},

        .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max }}, // 30
        .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max }},
        .{ .position = .{ .x = inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max - uv_max / 4 }},
        .{ .position = .{ .x = inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max - uv_max / 4 }},
    };

    const indices = [_]u16 {
        // top
        0, 1, 2,
        0, 2, 3,
        0, 3, 4,
        0, 4, 5,
        0, 5, 6,
        0, 6, 1,

        // bottom, opposite winding
        7, 9, 8,
        7, 10, 9,
        7, 11, 10,
        7, 12, 11,
        7, 13, 12,
        7, 8, 13,

        // sides
        14, 15, 16,
        17, 16, 15,

        18, 19, 20,
        21, 20, 19,

        22, 23, 24,
        25, 24, 23,

        26, 27, 28,
        29, 28, 27,

        30, 31, 32,
        33, 32, 31,

        32, 33, 14,
        14, 33, 15
    };

    var vertex_buffer = PerVertexBuffer {
        .label = webgpu.StringView.sized("vertices"),
        .length = vertices.len
    };
    vertex_buffer.create(device);
    vertex_buffer.upload(device.getQueue(), &vertices, 0);
    
    const grid_x = 100;
    const grid_y = 100;

    var instances: [grid_x * grid_y]Instance = undefined;

    for(0..grid_x) |x| {
        for (0..grid_y) |y| {
            const instance_index = x * grid_y + y;
            instances[instance_index] = Instance {
                .position = .{
                    .x = @floatFromInt(x),
                    .y = @floatFromInt(y),
                    .z = @as(f32, @floatFromInt(((x + y) % 2))) / 2
                },
                .texture = @intCast((x * y) % 4)
            };
        }
    }

    var instance_buffer = PerInstanceBuffer {
        .label = webgpu.StringView.sized("instances"),
        .length = instances.len
    };
    instance_buffer.create(device);
    instance_buffer.upload(device.getQueue(), &instances, 0);

    const index_buffer_descriptor = webgpu.BufferDescriptor {
        .usage = . { .index = true, .copy_dst = true },
        .size = indices.len * @sizeOf(u16)
    };
    const index_buffer = device.createBuffer(&index_buffer_descriptor);
    device.getQueue().writeBuffer(index_buffer, u16, &indices, 0);

    const bind_group_layout = createBindGroupLayout(device, .{});

    const pipeline_layout = createPipelineLayout(device, &.{bind_group_layout}, .{});


    const handle = createRenderPipeline(device, 
        pipeline_layout,
        surface.colorTextureFormat,
        vertex_shader,
        fragment_shader,
        .{});

    return .{
        .block_sampler = block_sampler,
        .block_texture = block_texture,
        .bind_group_layout = bind_group_layout,
        .vertex_buffer = vertex_buffer,
        .instance_buffer = instance_buffer,
        .index_buffer = index_buffer,
        .handle = handle
    };
}

const Vertex = extern struct {
    position: extern struct {
        x: f32,
        y: f32,
        z: f32
    },
    texture: extern struct {
        u: u16,
        v: u16,
    }
};

const Instance = extern struct {
    position: extern struct {
        x: f32,
        y: f32,
        z: f32
    },
    texture: u32
};

fn createRenderPipeline(device: *webgpu.Device,
    layout: *webgpu.PipelineLayout,
    color_texture_format: webgpu.TextureFormat,
    vertex_shader: Shader,
    fragment_shader: Shader,
    label: webgpu.StringView) *webgpu.RenderPipeline {

    const vertex_position_attribute = webgpu.VertexAttribute {
        .shader_location = 0,
        .format = .float32x3,
        .offset = 0
    };

    const uv_attribute = webgpu.VertexAttribute {
        .shader_location = 1,
        .format = .unorm16x2,
        .offset = VertexLayout.byteSize(vertex_position_attribute.format)
    };

    const instance_position_attribute = webgpu.VertexAttribute {
        .shader_location = 2,
        .format = .float32x3,
        .offset = 0
    };

    const texture_index_attribute = webgpu.VertexAttribute {
        .shader_location = 3,
        .format = .uint32,
        .offset = instance_position_attribute.offset + VertexLayout.byteSize(instance_position_attribute.format)
    };
    
    const vertex_attributes = [_]webgpu.VertexAttribute {
        vertex_position_attribute,
        uv_attribute,
    };
    
    const instance_attributes = [_]webgpu.VertexAttribute {
        instance_position_attribute,
        texture_index_attribute
    };

    const vertex_buffer_layout = webgpu.VertexBufferLayout {
        .array_stride = VertexLayout.byteSize(.float32x3) + VertexLayout.byteSize(.unorm16x2),
        .step_mode = .vertex,
        .attribute_count = vertex_attributes.len,
        .attributes = &vertex_attributes
    };

    const instance_buffer_layout = webgpu.VertexBufferLayout {
        .array_stride = VertexLayout.byteSize(.float32x3) + VertexLayout.byteSize(.uint32),
        .step_mode = .instance,
        .attribute_count = instance_attributes.len,
        .attributes = &instance_attributes
    };

    const vertex = webgpu.VertexState {
        .module = vertex_shader.module,
        .entry_point = vertex_shader.entry,
        .buffer_count = 2,
        .buffers = &.{
            vertex_buffer_layout,
            instance_buffer_layout
        },
        .constant_count = 0,
        .constants = null
    };

    const color_target = webgpu.ColorTargetState {
        .format = color_texture_format
    };

    const fragment = webgpu.FragmentState {
        .module = fragment_shader.module,
        .entry_point = fragment_shader.entry,
        .target_count = 1,
        .targets = &.{color_target},
        .constant_count = 0,
        .constants = null
    };

    const primitive = webgpu.PrimitiveState {
        .cull_mode = .back,
        .front_face = .counter_clockwise,
        .topology = .triangle_list,
        .strip_index_format = .undefined
    };

    const depth = webgpu.DepthStencilState {
        .format = .depth24_plus,
        .depth_compare = .less,
        .depth_write_enabled = .true
    };

    const descriptor = webgpu.RenderPipelineDescriptor {
        .label = label,
        .layout = layout,
        .vertex = vertex,
        .fragment = &fragment,
        .primitive = primitive,
        .depth_stencil = &depth,
        .multisample = .{}
    };

    return device.createRenderPipeline(&descriptor);
}

fn createPipelineLayout(device: *webgpu.Device, bind_group_layouts: []const *webgpu.BindGroupLayout, label: webgpu.StringView) *webgpu.PipelineLayout {

    const descriptor = webgpu.PipelineLayoutDescriptor {
        .label = label,
        .bind_group_layouts = bind_group_layouts.ptr,
        .bind_group_layout_count = bind_group_layouts.len
    };

    return device.createPipelineLayout(&descriptor);
}

fn createBindGroupLayout(device: *webgpu.Device, label: webgpu.StringView) *webgpu.BindGroupLayout {

    const Entry = webgpu.BindGroupLayoutEntry;

    const projection_buffer_entry = Entry {
        .binding = 0,
        .buffer = .{
            .type = .uniform,
        },
        .visibility = .{ .vertex =  true }
    };

    const sampler_entry = Entry {
        .binding = 1,
        .sampler = .{
            .type = .filtering
        },
        .visibility = .{ .fragment = true }
    };

    const texture_entry = Entry {
        .binding = 2,
        .texture = .{
            .sample_type = .float,
            .view_dimension = .@"2d_array",
            .multisampled = 0
        },
        .visibility = .{ .fragment = true }
    };

    const entries = [_]Entry {
        projection_buffer_entry,
        texture_entry,
        sampler_entry
    };

    const descriptor = webgpu.BindGroupLayoutDescriptor {
        .label = label,
        .entries = &entries,
        .entry_count = entries.len
    };

    return device.createBindGroupLayout(&descriptor);
}


fn createSampler(device: *webgpu.Device,
    addressMode: webgpu.AddressMode,
    filter: webgpu.FilterMode) *webgpu.Sampler {

	const descriptor = webgpu.SamplerDescriptor {
	    .address_mode_u  = addressMode,
	    .address_mode_v = addressMode,
	    .address_mode_w = addressMode,
	    .mag_filter = filter,
	    .min_filter = filter,
	    .mipmap_filter = filter,
    };
	
	return device.createSampler(&descriptor);
}
