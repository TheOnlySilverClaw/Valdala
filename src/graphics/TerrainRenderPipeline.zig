const webgpu = @import("webgpu");
const asset = @import("asset");

const Surface = @import("Surface.zig");
const Shader = @import("Shader.zig");

const Self = @This();

handle: *webgpu.RenderPipeline,
bindgroup_layout: *webgpu.BindGroupLayout,

pub fn init(surface: *const Surface) !Self {
    const shader_source = asset.shader.terrain[0..];
    const shader = Shader.load(shader_source, surface.device, "terrain");
    defer shader.release();

    const bindgroup_layout = createBindGroupLayout(surface.device);
    const handle = createRenderPipeline(surface, bindgroup_layout, shader);

    return .{ .handle = handle, .bindgroup_layout = bindgroup_layout };
}

pub fn deinit(self: Self) void {
    self.handle.release();
}

fn createRenderPipeline(surface: *const Surface, bindgroup_layout: *webgpu.BindGroupLayout, shader: *webgpu.ShaderModule) *webgpu.RenderPipeline {

    const device = surface.device;

    const bind_group_layouts = [_]*webgpu.BindGroupLayout { bindgroup_layout };

    const pipeline_layout_descriptor = webgpu.PipelineLayoutDescriptor {
        .label = .empty,
        .bind_group_layouts = &bind_group_layouts,
        .bind_group_layout_count = bind_group_layouts.len
    };

    const pipeline_layout = device.createPipelineLayout(&pipeline_layout_descriptor);

    const vertex_position_attribute = webgpu.VertexAttribute {
        .shader_location = 0,
        .format = .float32x3,
        .offset = 0
    };

    const uv_attribute = webgpu.VertexAttribute {
        .shader_location = 1,
        .format = .float16x2,
        .offset = vertex_position_attribute.format.size()
    };

    const texture_attribute = webgpu.VertexAttribute {
        .shader_location = 2,
        .format = .uint32,
        .offset = uv_attribute.offset + uv_attribute.format.size()
    };
    
    const vertex_attributes = [_]webgpu.VertexAttribute {
        vertex_position_attribute,
        uv_attribute,
        texture_attribute
    };
    
    const vertex_buffer_layout = webgpu.VertexBufferLayout {
        .array_stride = vertex_position_attribute.format.size() + uv_attribute.format.size() + texture_attribute.format.size(),
        .step_mode = .vertex,
        .attribute_count = vertex_attributes.len,
        .attributes = &vertex_attributes
    };

    const vertex_buffer_layouts = [_]webgpu.VertexBufferLayout { vertex_buffer_layout };

    const vertex = webgpu.VertexState {
        .module = shader,
        .entry_point = webgpu.StringView.sized("vertex"),
        .buffer_count = vertex_buffer_layouts.len,
        .buffers = &vertex_buffer_layouts,
        .constant_count = 0,
        .constants = null
    };

    const color_target = webgpu.ColorTargetState {
        .format = surface.getColorTextureFormat()
    };

    const fragment = webgpu.FragmentState {
        .module = shader,
        .entry_point = webgpu.StringView.sized("fragment"),
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
        .label = webgpu.StringView.sized("terrain"),
        .layout = pipeline_layout,
        .vertex = vertex,
        .fragment = &fragment,
        .primitive = primitive,
        .depth_stencil = &depth,
        .multisample = .{}
    };

    return device.createRenderPipeline(&descriptor);
}

fn createBindGroupLayout(device: *webgpu.Device) *webgpu.BindGroupLayout {

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
        .label = .empty,
        .entries = &entries,
        .entry_count = entries.len
    };

    return device.createBindGroupLayout(&descriptor);
}