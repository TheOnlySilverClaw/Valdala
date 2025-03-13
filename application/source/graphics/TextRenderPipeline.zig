const webgpu = @import("webgpu");

const VertexLayout = @import("VertexLayout.zig");

handle: *webgpu.RenderPipeline,

pub fn create(
    device: *webgpu.Device,
    textureFormat: webgpu.TextureFormat,
    shader: *webgpu.ShaderModule,
) @This() {
    
    const samplerEntry = webgpu.BindGroupLayoutEntry {
        .binding = 0,
        .visibility = .{ .fragment = true },
        .sampler = .{ .type = .filtering }
    };

    const samplerBindGroup = device.createBindGroupLayout(&.{
        .entries = &.{ samplerEntry },
        .entry_count = 1
    });

    const glyphTextureEntry = webgpu.BindGroupLayoutEntry {
        .binding = 0,
        .visibility = .{ .fragment = true },
        .texture = .{
            .multisampled = false,
            .type = .float,
            .view_dimension = .@"2d"
        }
    };

    const screenSizeEntry = webgpu.BindGroupLayoutEntry {
        .binding = 1,
        .visibility = .{ .vertex = true },
        .buffer = .{
            .type = .uniform,
            .min_binding_size = @sizeOf([2]f32)
        }
    };

    const textColorEntry = webgpu.BindGroupLayoutEntry {
        .binding = 2,
        .visibility = .{ .fragment = true },
        .buffer = .{
            .type = .uniform,
            .min_binding_size = 4 * 4
        }
    };

    const variableEntries = [_] webgpu.BindGroupLayoutEntry {
        glyphTextureEntry,
        screenSizeEntry,
        textColorEntry
    };

    const variableBindGroup = device.createBindGroupLayout(&.{
        .entries = variableEntries[0..],
        .entry_count = variableEntries.len
    });

    const bindGroupLayouts = [_] *webgpu.BindGroupLayout {
        samplerBindGroup,
        variableBindGroup,
    };

    const layoutDescriptor = webgpu.PipelineLayoutDescriptor {
        .bind_group_layout_count = bindGroupLayouts.len,
        .bind_group_layouts = bindGroupLayouts[0..]
    };

    const layout = device.createPipelineLayout(&layoutDescriptor);

    const target = webgpu.ColorTargetState {
        .format = textureFormat
    };

    const fragment = webgpu.FragmentState {
        .constant_count = 0,
        .constants = null,
        .entry_point = "fragment",
        .module = shader,
        .target_count = 1,
        .targets = &.{ target }
    };

    const vertexBuffer = VertexLayout.createBufferLayout(
        &.{ .float32x2, .float32x2 }, .vertex);

    const vertex = webgpu.VertexState {
        .constant_count = 0,
        .constants = null,
        .entry_point = "vertex",
        .module = shader,
        .buffer_count = 1,
        .buffers = &.{ vertexBuffer }
    };

    const primitive = webgpu.PrimitiveState {
        .cull_mode = .back,
        .front_face = .counter_clockwise,
        .topology = .triangle_list
    };

    // TODO split renderers into 2D and 3D? UI probably does not need depth 
    const depth = webgpu.DepthStencilState {
        .format = .depth24_plus,
        .depth_compare = .less
    };

    const descriptor = webgpu.RenderPipelineDescriptor {
        .label = "text renderer",
        .layout = layout,
        .depth_stencil = &depth,
        .fragment = &fragment,
        .vertex = vertex,
        .primitive = primitive,
        .multisample = .{}
    };

    const pipeline = device.createRenderPipeline(&descriptor);
    return .{ .handle = pipeline };
}
