const webgpu = @import("webgpu");

pub fn makeVertexState(attributes: anytype, shader: *webgpu.shader.ShaderModule) webgpu.render_pipeline.VertexState {
    var offset: usize = 0;

    var vertex_attributes: [attributes.len]webgpu.render_pipeline.VertexAttribute = undefined;
    for (attributes, 0..) |attribute, index| {

        const vertex_attribute = webgpu.render_pipeline.VertexAttribute {
            .shader_location = @intCast(index),
            .format = attribute,
            .offset = offset
        };
        offset += attribute.size();
        vertex_attributes[index] = vertex_attribute;
    }
    const vertex_buffer_layout = webgpu.render_pipeline.VertexBufferLayout {
        .array_stride = offset,
        .step_mode = .vertex,
        .attribute_count = vertex_attributes.len,
        .attributes = &vertex_attributes
    };

    const vertex_buffer_layouts = [_]webgpu.render_pipeline.VertexBufferLayout { vertex_buffer_layout };

    const vertex = webgpu.render_pipeline.VertexState {
        .module = shader,
        .entry_point = webgpu.StringView.sliced("vertex"),
        .buffer_count = vertex_buffer_layouts.len,
        .buffers = &vertex_buffer_layouts,
        .constant_count = 0,
        .constants = null
    };

    return vertex;
}
