const webgpu = @import("webgpu");

const pipeline = webgpu.render_pipeline;

pub fn MakeVertexInfo(format: anytype) type {
    return struct {
        const Self = @This();
        attributes: [format.len]pipeline.VertexAttribute,
        buffer_layout: [1]pipeline.VertexBufferLayout,
        vertex: pipeline.VertexState,

        pub fn init(shader: *webgpu.shader.ShaderModule) Self {
            var self: Self = undefined;
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

