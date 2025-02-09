const webgpu = @import("webgpu");

const VertexLayout = @import("VertexLayout.zig");

handle: webgpu.RenderPipeline,

pub fn create(
    device: webgpu.Device,
    textureFormat: webgpu.TextureFormat,
    shader: webgpu.ShaderModule,
) @This() {
    
    const samplerEntry = webgpu.BindGroupLayoutEntry {
        .binding = 0,
        .sampler = .{ .type = .filtering }
    };

    const samplerBindGroup = device.createBindGroupLayout(.{
        .entries = &samplerEntry,
        .entry_count = 1
    });

    const glyphTextureEntry = webgpu.BindGroupLayoutEntry {
        .binding = 0,
        .texture = .{
            .multisampled = false,
            .type = .float,
            .view_dimension = .@"2d"
        }
    };

    const glyphTextureBindGroup = device.createBindGroup(.{
        .entries = &glyphTextureEntry,
        .entry_count = 1
    });

    const screenSizeEntry = webgpu.BindGroupLayoutEntry {
        .binding = 0,
        .buffer = .{ .type = .uniform }
    };

    const screenSizeBindGroup = device.createBindGroupLayout(.{
        .entries = &screenSizeEntry,
        .entry_count = 1
    });

    const textColorEntry = webgpu.BindGroupLayoutEntry {
        .binding = 0,
        .buffer = .{ .type = .uniform }
    };

    const textColorBindGroup = device.createBindGroupLayout(.{
        .entries = &textColorEntry,
        .entry_count = 1
    });

    const bindGroupLayouts = .{
        samplerBindGroup,
        glyphTextureBindGroup,
        screenSizeBindGroup,
        textColorBindGroup
    };

    const layoutDescriptor = webgpu.PipelineLayoutDescriptor {
        .bind_group_layout_count = bindGroupLayouts.len,
        .bind_group_layouts = &bindGroupLayouts
    };

    const layout = device.createPipelineLayout(&layoutDescriptor);

    const target = webgpu.ColorTargetState {
        .format = textureFormat
    };

    const fragment = webgpu.FragmentState {
        .constant_count = 0,
        .constants = null,
        .entry_point = "",
        .module = shader,
        .target_count = 1,
        .targets = &target
    };

    const vertexBuffer = VertexLayout.createBufferLayout(
        .{ .float32x2, .float16x2 }, .vertex);

    const vertex = webgpu.VertexState {
        .constant_count = 0,
        .constants = null,
        .entry_point = "vertex",
        .module = shader,
        .buffer_count = 1,
        .buffers = &vertexBuffer
    };

    const primitive = webgpu.PrimitiveState {
        .cull_mode = .none,
        .front_face = .counter_clockwise,
        .topology = .triangle_list
    };

    const descriptor = webgpu.RenderPipelineDescriptor {
        .label = "text renderer",
        .layout = layout,
        .depth_stencil = null,
        .fragment = &fragment,
        .vertex = vertex,
        .primitive = primitive,
        .multisample = .{}
    };

    const pipeline = device.createRenderPipeline(&descriptor);
    return .{ .handle = pipeline };
}
