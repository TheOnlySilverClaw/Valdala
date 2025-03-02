const std = @import("std");
const Allocator = std.mem.Allocator;
const webgpu = @import("webgpu");
const Surface = @import("Surface.zig");
const VertexBuffer = @import("VertexBuffer.zig").VertexBuffer(Vertex, &.{.float32x3, .unorm16x2, .uint32 });
const VertexLayout = @import("VertexLayout.zig");
const Shader = @import("shader.zig").Shader;
const TextureArray = @import("TextureArray.zig");

const Self = @This();


block_sampler: webgpu.Sampler,
block_texture: TextureArray,
vertex_buffer: VertexBuffer,
index_buffer: webgpu.Buffer,
bind_group_layout: webgpu.BindGroupLayout,
handle: webgpu.RenderPipeline,


pub fn create(allocator: Allocator, surface: *const Surface) !Self {

    const device = surface.device;

    const block_sampler = createSampler(device, .repeat, .nearest);

    const shader_module = try Shader.loadModule(allocator, device, "shaders/textured.wgsl", "textured");
    const vertex_shader = Shader {
        .entry = "vertex",
        .module =  shader_module
    };
    const fragment_shader = Shader {
        .entry = "fragment",
        .module = shader_module
    };

    var block_texture = TextureArray {
        .label = "blocks",
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

    const max = std.math.maxInt(u16);

    const size: f32 = 0.5;
    const z : f32 = 0.5;
    const vertices = [_]Vertex {
        .{ .position = .{.x = -size, .y = size, .z = z }, .texture = .{.u = 0, .v = 0, .index = 0 }},
        .{ .position = .{.x = -size, .y = -size, .z = z }, .texture = .{.u = 0, .v = max, .index = 0 }},
        .{ .position = .{.x = size, .y = -size, .z = z }, .texture = .{.u = max, .v = max, .index = 0 }},  
        .{ .position = .{.x = size, .y = size, .z = z }, .texture = .{.u = max, .v = 0, .index = 0 }}
    };

    const indices = [_]u16 {
        0, 1, 2,
        2, 3, 0
    };

    var vertex_buffer = VertexBuffer {
        .label = "vertices",
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

    const bind_group_layout = createBindGroupLayout(device, null);

    const pipeline_layout = createPipelineLayout(device, &.{bind_group_layout}, null);


    const handle = createRenderPipeline(device, 
        pipeline_layout,
        surface.colorTextureFormat,
        vertex_shader,
        fragment_shader,
        null);

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

fn createRenderPipeline(device: webgpu.Device,
    layout: webgpu.PipelineLayout,
    color_texture_format: webgpu.TextureFormat,
    vertex_shader: Shader,
    fragment_shader: Shader,
    label: ?[*:0]const u8) webgpu.RenderPipeline {

    const bufferLayout = VertexLayout.createBufferLayout(&.{.float32x3, .unorm16x2, .uint32 }, .vertex);

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

fn createPipelineLayout(device: webgpu.Device, bind_group_layouts: []const webgpu.BindGroupLayout, label: ?[*:0]const u8) webgpu.PipelineLayout {

    const descriptor = webgpu.PipelineLayoutDescriptor {
        .label = label,
        .bind_group_layouts = bind_group_layouts.ptr,
        .bind_group_layout_count = bind_group_layouts.len
    };

    return device.createPipelineLayout(&descriptor);
}

fn createBindGroupLayout(device: webgpu.Device, label: ?[*:0]const u8) webgpu.BindGroupLayout {

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
            .type = .float,
            .view_dimension = .@"2d_array",
            .multisampled = false
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


fn createSampler(device: webgpu.Device,
    addressMode: webgpu.AddressMode,
    filter: webgpu.FilterMode) webgpu.Sampler {

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
