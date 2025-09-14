const webgpu = @import("webgpu");


handle: *webgpu.RenderPipeline,

pub fn create(device: *webgpu.Device, texture_format: webgpu.TextureFormat, shader: *webgpu.ShaderModule) @This() {
    
    const sampler_entry = webgpu.BindGroupLayoutEntry {
        .binding = 0,
        .visibility = .{ .fragment = true },
        .sampler = .{ .type = .filtering }
    };

    const sampler_bindgroup = device.createBindGroupLayout(&.{
        .entries = &.{ sampler_entry },
        .entry_count = 1
    });

    const glyph_texture_entry = webgpu.BindGroupLayoutEntry {
        .binding = 0,
        .visibility = .{ .fragment = true },
        .texture = .{
            .multisampled = 0,
            .sample_type = .float,
            .view_dimension = .@"2d"
        }
    };

    const variable_entries = [_] webgpu.BindGroupLayoutEntry {
        glyph_texture_entry,
    };

    const variable_bindgroup = device.createBindGroupLayout(&.{
        .entries = variable_entries[0..],
        .entry_count = variable_entries.len
    });

    const bindgroup_layouts = [_] *webgpu.BindGroupLayout {
        sampler_bindgroup,
        variable_bindgroup,
    };

    const layout_descriptor = webgpu.PipelineLayoutDescriptor {
        .bind_group_layout_count = bindgroup_layouts.len,
        .bind_group_layouts = bindgroup_layouts[0..]
    };

    const pipeline_layout = device.createPipelineLayout(&layout_descriptor);

    const color_target = webgpu.ColorTargetState {
        .format = texture_format
    };

    const fragment = webgpu.FragmentState {
        .constant_count = 0,
        .constants = null,
        .entry_point = webgpu.StringView.sized("fragment"),
        .module = shader,
        .target_count = 1,
        .targets = &.{ color_target }
    };

    const position_attribute = webgpu.VertexAttribute {
        .shader_location = 0,
        .format = .float32x2,
        .offset = 0
    };

    const uv_attribute = webgpu.VertexAttribute {
        .shader_location = 1,
        .format = .float32x2,
        .offset = position_attribute.format.size()
    };

    const color_attribute = webgpu.VertexAttribute {
        .shader_location = 2,
        .format = .float32x4,
        .offset = position_attribute.format.size() + uv_attribute.format.size()
    };

    const attributes = [_]webgpu.VertexAttribute {
        position_attribute,
        uv_attribute,
        color_attribute
    };

    const vertexBuffer = webgpu.VertexBufferLayout {
        .array_stride = position_attribute.format.size() + uv_attribute.format.size() + color_attribute.format.size(),
        .step_mode = .vertex,
        .attribute_count = attributes.len,
        .attributes = &attributes
    };

    const vertex = webgpu.VertexState {
        .constant_count = 0,
        .constants = null,
        .entry_point = webgpu.StringView.sized("vertex"),
        .module = shader,
        .buffer_count = 1,
        .buffers = &.{ vertexBuffer }
    };

    const primitive = webgpu.PrimitiveState {
        .cull_mode = .back,
        .front_face = .counter_clockwise,
        .topology = .triangle_list
    };


    const descriptor = webgpu.RenderPipelineDescriptor {
        .label = webgpu.StringView.sized("text renderer"),
        .layout = pipeline_layout,
        .depth_stencil = null,
        .fragment = &fragment,
        .vertex = vertex,
        .primitive = primitive,
        .multisample = .{},
    };

    const pipeline = device.createRenderPipeline(&descriptor);
    return .{ .handle = pipeline };
}
