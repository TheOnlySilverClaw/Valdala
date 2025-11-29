const webgpu = @import("webgpu");
const asset = @import("asset");

const Surface = @import("Surface.zig");
const Shader = @import("Shader.zig");


const RenderPipeline = @import("RenderPipeline.zig");
const scene= @import("scene");
const Self = @This();

handle: *webgpu.render_pipeline.RenderPipeline,
static_bind_group_layout: *webgpu.bind_group_layout.BindGroupLayout,
dynamic_bind_group_layout: *webgpu.bind_group_layout.BindGroupLayout,

pub fn init(surface: *const Surface) !Self {

    const shader_source = asset.shader.enity[0..];
    const shader = Shader.load(shader_source, surface.device, "entity");
    defer shader.release();

    const static_bind_group_layout = createStaticBindGroupLayout(surface.device);
    const dynamic_bind_group_layout = createDynamicBindGroupLayout(surface.device);

    const handle = createRenderPipeline(surface, static_bind_group_layout, dynamic_bind_group_layout, shader);

    return .{
        .handle = handle,
        .static_bind_group_layout = static_bind_group_layout,
        .dynamic_bind_group_layout = dynamic_bind_group_layout
    };
}

pub fn deinit(self: Self) void {

    self.handle.release();
    self.static_bind_group_layout.release();
    self.dynamic_bind_group_layout.release();
}

fn createRenderPipeline(surface: *const Surface, static_bind_group_layout: *webgpu.bind_group_layout.BindGroupLayout, dynamic_bind_group_layout: *webgpu.bind_group_layout.BindGroupLayout, shader: *webgpu.shader.ShaderModule) *webgpu.render_pipeline.RenderPipeline {

    const device = surface.device;

    const bind_group_layouts = [_]*webgpu.bind_group_layout.BindGroupLayout {
        static_bind_group_layout,
        dynamic_bind_group_layout
    };

    const pipeline_layout_descriptor = webgpu.pipeline_layout.PipelineLayoutDescriptor {
        .label = .empty,
        .bind_group_layouts = &bind_group_layouts,
        .bind_group_layout_count = bind_group_layouts.len
    };

    const pipeline_layout = device.createPipelineLayout(&pipeline_layout_descriptor);

    const vertex_info= RenderPipeline.MakeVertexInfo(scene.EntityMesh.Vertex.format).init(shader);

    const color_target = webgpu.render_pipeline.ColorTargetState {
        .format = surface.getColorTextureFormat()
    };

    const fragment = webgpu.render_pipeline.FragmentState {
        .module = shader,
        .entry_point = webgpu.StringView.sliced("fragment"),
        .target_count = 1,
        .targets = &.{color_target},
        .constant_count = 0,
        .constants = null
    };

    const primitive = webgpu.render_pipeline.PrimitiveState {
        .cull_mode = .back,
        .front_face = .counter_clockwise,
        .topology = .triangle_list,
        .strip_index_format = .undefined
    };

    const depth = webgpu.render_pipeline.DepthStencilState {
        .format = .depth24_plus,
        .depth_compare = .less,
        .depth_write_enabled = .true
    };

    const descriptor = webgpu.render_pipeline.RenderPipelineDescriptor {
        .label = webgpu.StringView.sliced("entity"),
        .layout = pipeline_layout,
        .vertex = vertex_info.vertex,
        .fragment = &fragment,
        .primitive = primitive,
        .depth_stencil = &depth,
        .multisample = .{}
    };

    return device.createRenderPipeline(&descriptor);
}

fn createStaticBindGroupLayout(device: *webgpu.device.Device) *webgpu.bind_group_layout.BindGroupLayout {

    const Entry = webgpu.bind_group_layout.BindGroupLayoutEntry;

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

    const entries = [_]Entry {
        projection_buffer_entry,
        sampler_entry
    };

    const descriptor = webgpu.bind_group_layout.BindGroupLayoutDescriptor {
        .label = .empty,
        .entries = &entries,
        .entry_count = entries.len
    };

    return device.createBindGroupLayout(&descriptor);
}

fn createDynamicBindGroupLayout(device: *webgpu.device.Device) *webgpu.bind_group_layout.BindGroupLayout {

    const Entry = webgpu.bind_group_layout.BindGroupLayoutEntry;

    const transform_buffer_entry = Entry {
        .binding = 0,
        .buffer = .{
            .type = .uniform,
            .has_dynamic_offset = 1,
            .min_binding_size = 256
        },
        .visibility = .{ .vertex =  true }
    };

    const color_texture_entry = Entry {
        .binding = 1,
        .texture = .{
            .sample_type = .float,
            .view_dimension = .@"2d"
        },
        .visibility = .{ .fragment =  true }
    };

    const entries = [_]Entry {
        transform_buffer_entry,
        color_texture_entry
    };

    const descriptor = webgpu.bind_group_layout.BindGroupLayoutDescriptor {
        .label = .empty,
        .entries = &entries,
        .entry_count = entries.len
    };

    return device.createBindGroupLayout(&descriptor);
}
