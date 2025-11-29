const webgpu = @import("webgpu");

const pipeline = webgpu.render_pipeline;

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

pub fn makeVertexInfo(format: anytype) type {
    return struct {
        const Self = @This();
        attributes: [format.len]pipeline.VertexAttribute,
        buffer_layout: [1]pipeline.VertexBufferLayout,
        vertex: pipeline.VertexState,

        pub fn init(shader: *webgpu.shader.ShaderModule) Self {
            var self = Self{
                .attributes = undefined,
                .buffer_layout = undefined,
                .vertex = undefined,
            };
            var offset: usize = 0;
            for (format, 0..) |attribute, index| {
                self.attributes[index] = webgpu.render_pipeline.VertexAttribute {
                    .shader_location = @intCast(index),
                    .format = attribute,
                    .offset = offset
                };
                offset += attribute.size();
            }

            self.buffer_layout[0] = webgpu.render_pipeline.VertexBufferLayout {
                .array_stride = offset,
                .step_mode = .vertex,
                .attribute_count = format.len,
                .attributes = &self.attributes
            };

            self.vertex = webgpu.render_pipeline.VertexState {
                .module = shader,
                .entry_point = webgpu.StringView.sliced("vertex"),
                .buffer_count = 1,
                .buffers = &self.buffer_layout,
                .constant_count = 0,
                .constants = null
            };
            return self;
        }
    };
}

