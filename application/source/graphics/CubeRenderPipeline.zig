const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;
const webgpu = @import("webgpu");
const Surface = @import("Surface.zig");
const VertexBuffer = @import("VertexBuffer.zig").VertexBuffer(Vertex, &.{.float32x3, .unorm16x2, .uint32 });
const VertexLayout = @import("VertexLayout.zig");
const Shader = @import("shader.zig").Shader;
const TextureArray = @import("TextureArray.zig");

const Self = @This();


block_sampler: *webgpu.Sampler,
block_texture: TextureArray,
vertex_buffer: VertexBuffer,
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
        .{ .position = .{ .x = 0, .y = 0, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max / 2, .index = 0 }}, // 0 - M_t
        .{ .position = .{ .x = inner, .y = size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max / 4, .index = 0 }}, // A_t
        .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = 0, .index = 0 }},  
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max - uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max, .index = 0 }},
        .{ .position = .{ .x = inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max - uv_max / 4, .index = 0 }},

        // bottom
        .{ .position = .{ .x = 0, .y = 0, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max / 2, .index = 0 }}, // 7 - M_b
        .{ .position = .{ .x = inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max / 4, .index = 0 }}, // A_b
        .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = 0, .index = 0 }},  
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max - uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max, .index = 0 }},
        .{ .position = .{ .x = inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max - uv_max / 4, .index = 0 }},

        // sides
        .{ .position = .{ .x = inner, .y = size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max / 4, .index = 0 }}, // 14
        .{ .position = .{ .x = inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = 0, .index = 0 }},  
        .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = 0, .index = 0 }},

        .{ .position = .{ .x = 0, .y = size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = 0, .index = 0 }},  // 18
        .{ .position = .{ .x = 0, .y = size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = 0, .index = 0 }},
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max / 4, .index = 0 }},

        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max / 4, .index = 0 }}, // 22
        .{ .position = .{ .x = -inner, .y = size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max - uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max - uv_max / 4, .index = 0 }},

        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 0, .v = uv_max - uv_max / 4, .index = 0 }}, // 26
        .{ .position = .{ .x = -inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 0, .v = uv_max - uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max, .index = 0 }},
        .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max, .index = 0 }},

        .{ .position = .{ .x = 0, .y = -size, .z = z_top }, .texture = .{.u = uv_max / 2, .v = uv_max, .index = 0 }}, // 30
        .{ .position = .{ .x = 0, .y = -size, .z = z_bottom }, .texture = .{.u = uv_max / 2, .v = uv_max, .index = 0 }},
        .{ .position = .{ .x = inner, .y = -size / 2, .z = z_top }, .texture = .{.u = 1, .v = uv_max - uv_max / 4, .index = 0 }},
        .{ .position = .{ .x = inner, .y = -size / 2, .z = z_bottom }, .texture = .{.u = 1, .v = uv_max - uv_max / 4, .index = 0 }},
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

    var vertex_buffer = VertexBuffer {
        .label = webgpu.StringView.sized("vertices"),
        .length = vertices.len
    };
    vertex_buffer.create(device);
    vertex_buffer.upload(device.getQueue(), &vertices, 0);
    
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
        index: u32
    }
};

fn createRenderPipeline(device: *webgpu.Device,
    layout: *webgpu.PipelineLayout,
    color_texture_format: webgpu.TextureFormat,
    vertex_shader: Shader,
    fragment_shader: Shader,
    label: webgpu.StringView) *webgpu.RenderPipeline {

    const position_attribute = webgpu.VertexAttribute {
        .shader_location = 0,
        .format = .float32x3,
        .offset = 0
    };

    const uv_attribute = webgpu.VertexAttribute {
        .shader_location = 1,
        .format = .unorm16x2,
        .offset = VertexLayout.byteSize(position_attribute.format)
    };

    const texture_index_attribute = webgpu.VertexAttribute {
        .shader_location = 2,
        .format = .uint32,
        .offset = uv_attribute.offset + VertexLayout.byteSize(uv_attribute.format)
    };

    const attributes = [_]webgpu.VertexAttribute {
        position_attribute,
        uv_attribute,
        texture_index_attribute
    };

    const bufferLayout = webgpu.VertexBufferLayout {
        .array_stride = VertexLayout.byteSize(.float32x3) + VertexLayout.byteSize(.unorm16x2) + VertexLayout.byteSize(.uint32),
        .step_mode = .vertex,
        .attribute_count = attributes.len,
        .attributes = &attributes
    };

    const vertex = webgpu.VertexState {
        .module = vertex_shader.module,
        .entry_point = vertex_shader.entry,
        .buffer_count = 1,
        .buffers = &.{ bufferLayout },
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
        .cull_mode = .none,
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

    const vertexBufferEntry = Entry {
        .binding = 0,
        .buffer = .{
            .type = .uniform,
        },
        .visibility = .{ .vertex =  true }
    };

    const samplerEntry = Entry {
        .binding = 1,
        .sampler = .{
            .type = .filtering
        },
        .visibility = .{ .fragment = true }
    };

    const textureEntry = Entry {
        .binding = 2,
        .texture = .{
            .sample_type = .float,
            .view_dimension = .@"2d_array",
            .multisampled = 0
        },
        .visibility = .{ .fragment = true }
    };

    const entries = [_]Entry {
        vertexBufferEntry,
        textureEntry,
        samplerEntry
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
