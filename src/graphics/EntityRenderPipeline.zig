const webgpu = @import("webgpu");
const asset = @import("asset");
const algebra = @import("algebra");

const Surface = @import("Surface.zig");
const Shader = @import("Shader.zig");
const Device = webgpu.device.Device;
const BindGroupLayout = webgpu.bind_group_layout.BindGroupLayout;
const BindGroupLayoutEntry = webgpu.bind_group_layout.BindGroupLayoutEntry;
const Limits = webgpu.support.Limits;
const Transform = algebra.Transform(f32);

const RenderPipeline = @import("RenderPipeline.zig");
const scene= @import("scene");
const Self = @This();

handle: *webgpu.render_pipeline.RenderPipeline,
static_bind_group_layout: *BindGroupLayout,
material_bind_group_layout: *BindGroupLayout,
node_bind_group_layout: *BindGroupLayout,

pub fn init(surface: *const Surface) !Self {

    const shader_source = asset.shader.enity[0..];
    const shader = Shader.load(shader_source, surface.device, "entity");
    defer shader.release();

    const static_bind_group_layout = createStaticBindGroupLayout(surface.device);
    const material_bind_group_layout = createMaterialBindGroupLayout(surface.device, surface.device_limits);
    const node_bind_group_layout = createNodeBindGroupLayout(surface.device, surface.device_limits);
    
    const bind_group_layouts = [_]*BindGroupLayout {
        static_bind_group_layout,
        material_bind_group_layout,
        node_bind_group_layout
    };

    const handle = createRenderPipeline(surface, &bind_group_layouts, shader);

    return .{
        .handle = handle,
        .static_bind_group_layout = static_bind_group_layout,
        .material_bind_group_layout = material_bind_group_layout,
        .node_bind_group_layout = node_bind_group_layout
    };
}

pub fn deinit(self: Self) void {

    self.handle.release();
    self.static_bind_group_layout.release();
    self.material_bind_group_layout.release();
    self.node_bind_group_layout.release();
}

fn createRenderPipeline(surface: *const Surface, bind_group_layouts: []const *webgpu.bind_group_layout.BindGroupLayout, shader: *webgpu.shader.ShaderModule) *webgpu.render_pipeline.RenderPipeline {

    const device = surface.device;

    const pipeline_layout_descriptor = webgpu.pipeline_layout.PipelineLayoutDescriptor {
        .label = .empty,
        .bind_group_layouts = bind_group_layouts.ptr,
        .bind_group_layout_count = bind_group_layouts.len
    };

    const pipeline_layout = device.createPipelineLayout(&pipeline_layout_descriptor);

    const vertex_info= RenderPipeline.MakeVertexInfo(scene.EntityModel.Vertex.format).init(shader);

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

fn createStaticBindGroupLayout(device: *webgpu.device.Device) *BindGroupLayout {

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
        .label = .sliced("static"),
        .entries = &entries,
        .entry_count = entries.len
    };

    return device.createBindGroupLayout(&descriptor);
}

fn createMaterialBindGroupLayout(device: *webgpu.device.Device, limits: Limits) *BindGroupLayout {

    const material_buffer_entry = BindGroupLayoutEntry {
        .binding = 0,
        .buffer = .{
            .type = .uniform,
            .has_dynamic_offset = 1,
            .min_binding_size =  RenderPipeline.uniformBufferAlignment(Transform, limits)
        },
        .visibility = .{ .vertex =  true }
    };

    const color_texture_entry = BindGroupLayoutEntry {
        .binding = 1,
        .texture = .{
            .sample_type = .float,
            .view_dimension = .@"2d"
        },
        .visibility = .{ .fragment =  true }
    };

    const entries = [_]BindGroupLayoutEntry {
        material_buffer_entry,
        color_texture_entry
    };

    const descriptor = webgpu.bind_group_layout.BindGroupLayoutDescriptor {
        .label = .sliced("material"),
        .entries = &entries,
        .entry_count = entries.len
    };

    return device.createBindGroupLayout(&descriptor);
}

fn createNodeBindGroupLayout(device: *webgpu.device.Device, limits: webgpu.support.Limits) *BindGroupLayout {


    const node_buffer_entry = BindGroupLayoutEntry {
        .binding = 0,
        .buffer = .{
            .type = .uniform,
            .has_dynamic_offset = 1,
            .min_binding_size =  RenderPipeline.uniformBufferAlignment(Transform, limits)
        },
        .visibility = .{ .vertex =  true }
    };

    const entries = [_]BindGroupLayoutEntry {
        node_buffer_entry
    };

    const descriptor = webgpu.bind_group_layout.BindGroupLayoutDescriptor {
        .label = .sliced("node"),
        .entries = &entries,
        .entry_count = entries.len
    };

    return device.createBindGroupLayout(&descriptor);
}
