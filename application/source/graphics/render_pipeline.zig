const std = @import("std");
const Allocator = std.mem.Allocator;
const webgpu = @import("webgpu");
const Device = webgpu.device.Device;
const Surface = @import("surface.zig").Surface;
const VertexBuffer = @import("vertex_buffer.zig").VertexBuffer(Vertex, &.{.float32x3, .unorm16x2, .uint32 });
const Shader = @import("shader.zig").Shader;
const texture = @import("texture.zig");


pub const RenderPipeline = struct {

    block_sampler: webgpu.sampler.Sampler,
    block_texture: texture.TextureArray,
    vertex_buffer: VertexBuffer,
    index_buffer: webgpu.buffer.Buffer,
    bind_group_layout: webgpu.bind_group_layout.BindGroupLayout,
    handle: webgpu.render_pipeline.RenderPipeline,


    pub fn create(allocator: Allocator, surface: Surface) !RenderPipeline {

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

        var block_texture = texture.TextureArray {
            .label = "blocks",
            .format = surface.color_texture_format,
            .width = 16,
            .height = 16,
            .layers = 4
        };
        block_texture.create(device);
        
        try block_texture.loadImages(allocator, surface.queue, &.{
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
        vertex_buffer.upload(device.getQueue(), &vertices);
        
        const index_buffer_descriptor = webgpu.buffer.BufferDescriptor {
            .usage = . { .index = true, .copy_dst = true },
            .size = indices.len * @sizeOf(u16)
        };
        const index_buffer = device.createBuffer(&index_buffer_descriptor);
        device.getQueue().writeBuffer(index_buffer, u16, &indices, 0);

        const bind_group_layout = createBindGroupLayout(device, null);

        const pipeline_layout = createPipelineLayout(device, &.{bind_group_layout}, null);

        const handle = createRenderPipeline(device, 
            pipeline_layout,
            surface.color_texture_format,
            &.{ VertexBuffer.layout() },
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
};

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

fn createRenderPipeline(device: webgpu.device.Device,
    layout: webgpu.pipeline_layout.PipelineLayout,
    color_texture_format: webgpu.texture.TextureFormat,
    buffer_layouts: []const webgpu.render_pipeline.VertexBufferLayout,
    vertex_shader: Shader,
    fragment_shader: Shader,
    label: ?[*:0]const u8) webgpu.render_pipeline.RenderPipeline {

    const vertex = webgpu.render_pipeline.VertexState {
        .module = vertex_shader.module,
        .entry_point = vertex_shader.entry,
        .buffer_count = buffer_layouts.len,
        .buffers = buffer_layouts.ptr,
        .constant_count = 0,
        .constants = null
    };

    const color_target = webgpu.render_pipeline.ColorTargetState {
        .format = color_texture_format
    };

    const fragment = webgpu.render_pipeline.FragmentState {
        .module = fragment_shader.module,
        .entry_point = fragment_shader.entry,
        .target_count = 1,
        .targets = &.{color_target},
        .constant_count = 0,
        .constants = null
    };

    const primitive = webgpu.render_pipeline.PrimitiveState {
        .cull_mode = .none,
        .front_face = .counter_clockwise,
        .topology = .triangle_list,
        .strip_index_format = .undefined
    };

    const descriptor = webgpu.render_pipeline.RenderPipelineDescriptor {
        .label = label,
        .layout = layout,
        .vertex = vertex,
        .fragment = &fragment,
        .primitive = primitive,
        .depth_stencil = null,
        .multisample = .{}
    };

    return device.createRenderPipeline(&descriptor);
}

fn createPipelineLayout(device: Device, bind_group_layouts: []const webgpu.bind_group_layout.BindGroupLayout, label: ?[*:0]const u8) webgpu.pipeline_layout.PipelineLayout {

    const descriptor = webgpu.pipeline_layout.PipelineLayoutDescriptor {
        .label = label,
        .bind_group_layouts = bind_group_layouts.ptr,
        .bind_group_layout_count = bind_group_layouts.len
    };

    return device.createPipelineLayout(&descriptor);
}

fn createBindGroupLayout(device: Device, label: ?[*:0]const u8) webgpu.bind_group_layout.BindGroupLayout {

    const Entry = webgpu.bind_group_layout.BindGroupLayoutEntry;

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

    const descriptor = webgpu.bind_group_layout.BindGroupLayoutDescriptor {
        .label = label,
        .entries = &entries,
        .entry_count = entries.len
    };

    return device.createBindGroupLayout(&descriptor);
}


fn createSampler(device: Device,
    addressMode: webgpu.sampler.AddressMode,
    filter: webgpu.sampler.FilterMode) webgpu.sampler.Sampler {

	const descriptor = webgpu.sampler.SamplerDescriptor {
	    .address_mode_u  = addressMode,
	    .address_mode_v = addressMode,
	    .address_mode_w = addressMode,
	    .mag_filter = filter,
	    .min_filter = filter,
	    .mipmap_filter = filter,
    };
	
	return device.createSampler(&descriptor);
}

