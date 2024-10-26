const std = @import("std");
const Allocator = std.mem.Allocator;
const webgpu = @import("webgpu");
const Device = webgpu.device.Device;
const VertexBuffer = @import("vertex_buffer.zig").VertexBuffer;
const Shader = @import("shader.zig").Shader;

pub const RenderPipeline = struct {

    block_sampler: webgpu.sampler.Sampler,

    pub fn create(allocator: Allocator, device: Device) !RenderPipeline {

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

        const handle = createRenderPipeline(device, undefined, undefined, vertex_shader, fragment_shader);
        _ = handle;

        const TypedVertexBuffer = VertexBuffer(Vertex, &.{.float32x3, .unorm16x2, .uint32});
        const vertex_buffer = TypedVertexBuffer.create(device, 4, null);
        const size: f32 = 0.5;
        const z : f32 = 0.5;
        const vertices: [4]Vertex = .{
            .{ .position = .{.x = -size, .y = size, .z = z }, .texture = .{.u = 0, .v = 0, .index = 0 }},
            .{ .position = .{.x = -size, .y = -size, .z = z }, .texture = .{.u = 0, .v = 1, .index = 0 }},
            .{ .position = .{.x = size, .y = -size, .z = z }, .texture = .{.u = 1, .v = 1, .index = 0 }},
            .{ .position = .{.x = size, .y = size, .z = z }, .texture = .{.u = 1, .v = 0, .index = 0 }},
        };
        vertex_buffer.upload(device.getQueue(), &vertices, 0);
        vertex_buffer.destroy();

        return .{
            .block_sampler = block_sampler
        };
    }
};

const Vertex = struct {
    position: struct {
        x: f32,
        y: f32,
        z: f32
    },
    texture: struct {
        u: u8,
        v: u8,
        index: u32
    }
};

fn createRenderPipeline(device: webgpu.device.Device,
    layout: webgpu.pipeline_layout.PipelineLayout,
    color_texture_format: webgpu.texture.TextureFormat,
    vertex_shader: Shader, fragment_shader: Shader) webgpu.render_pipeline.RenderPipeline {

    const vertex = webgpu.render_pipeline.VertexState {
        .module = vertex_shader.module,
        .entry_point = vertex_shader.entry,
        .buffer_count = 0,
        .buffers = null,
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
        .layout = layout,
        .vertex = vertex,
        .fragment = &fragment,
        .primitive = primitive,
        .depth_stencil = null,
        .multisample = .{}
    };

    return device.createRenderPipeline(&descriptor);
}

fn createPipelineLayout(device: Device, bind_group_layouts: []const webgpu.bind_group_layout.BindGroupLayout) webgpu.pipeline_layout.PipelineLayout {

    const descriptor = webgpu.pipeline_layout.PipelineLayoutDescriptor {
        .bind_group_layout_count = bind_group_layouts.len,
        .bind_group_layouts = bind_group_layouts.ptr
    };

    return device.createPipelineLayout(&descriptor);
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

