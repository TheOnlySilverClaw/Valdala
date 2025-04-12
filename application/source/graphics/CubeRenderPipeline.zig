const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;
const webgpu = @import("webgpu");
const hexagon = @import("hexagon.zig");

const Surface = @import("Surface.zig");
const VertexBuffer = @import("VertexBuffer.zig").VertexBuffer;
const PerVertexBuffer = VertexBuffer(hexagon.Vertex, &.{.float32x3, .float16x2 });
const PerInstanceBuffer = VertexBuffer(Instance, &.{ .float32x3, .uint32 });
const VertexLayout = @import("VertexLayout.zig");
const Shader = @import("shader.zig").Shader;
const TextureArray = @import("TextureArray.zig");
const Random2D = @import("common").Random2d;

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
        "textures/terrain/grass.qoi",
        "textures/terrain/water.qoi",
        "textures/terrain/rock.qoi",
        "textures/terrain/sand.qoi",
    });

    const mesh = hexagon.Mesh.instance();

    var vertex_buffer = PerVertexBuffer {
        .label = webgpu.StringView.sized("vertices"),
        .length = hexagon.Mesh.vertex_count
    };
    vertex_buffer.create(device);
    vertex_buffer.upload(device.getQueue(), &mesh.vertices, 0);
    
    const grid_x = 100;
    const grid_y = 100;

    var instances: [grid_x * grid_y]Instance = undefined;
    var random = Random2D.new(@intCast(std.time.milliTimestamp()));

    for(0..grid_x) |x| {
        for (0..grid_y) |y| {
            const instance_index = x + y * grid_x;
            const position = hexagon.Mesh.gridPosition(x, y, 1.0);
            instances[instance_index] = Instance {
                .position = position,
                .texture = @intCast(random.get(@intFromFloat(position.x), @intFromFloat(position.y)) % 4)
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
        .size = hexagon.Mesh.index_count * @sizeOf(hexagon.Index)
    };
    const index_buffer = device.createBuffer(&index_buffer_descriptor);
    device.getQueue().writeBuffer(index_buffer, hexagon.Index, &mesh.indices, 0);

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

const Instance = extern struct {
    position: hexagon.Position,
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
        .format = .float16x2,
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
        .array_stride = VertexLayout.byteSize(vertex_position_attribute.format) + VertexLayout.byteSize(uv_attribute.format),
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
