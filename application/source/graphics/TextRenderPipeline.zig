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
            .multisampled = 0,
            .sample_type = .float,
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
        .entry_point = webgpu.StringView.sized("fragment"),
        .module = shader,
        .target_count = 1,
        .targets = &.{ target }
    };

    const position_attribute = webgpu.VertexAttribute {
        .shader_location = 0,
        .format = .float32x2,
        .offset = 0
    };

    const uv_attribute = webgpu.VertexAttribute {
        .shader_location = 1,
        .format = .float32x2,
        .offset = VertexLayout.byteSize(position_attribute.format)
    };

    const attributes = [_]webgpu.VertexAttribute {
        position_attribute,
        uv_attribute
    };

    const vertexBuffer = webgpu.VertexBufferLayout {
        .array_stride = VertexLayout.byteSize(.float32x2) + VertexLayout.byteSize(.float32x2),
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

    // TODO split renderers into 2D and 3D? UI probably does not need depth 
    const depth = webgpu.DepthStencilState {
        .format = .depth24_plus,
        .depth_compare = .less,
        .depth_write_enabled = .true
    };

    const descriptor = webgpu.RenderPipelineDescriptor {
        .label = webgpu.StringView.sized("text renderer"),
        .layout = layout,
        .depth_stencil = &depth,
        .fragment = &fragment,
        .vertex = vertex,
        .primitive = primitive,
        .multisample = .{}
    };

    @import("std").log.debug("layouts: {x} {x}", .{ @intFromEnum(vertexBuffer.attributes[0].format), @intFromEnum(vertexBuffer.attributes[1].format)});
    const pipeline = device.createRenderPipeline(&descriptor);
    @import("std").log.debug("layouts: {x} {x}", .{ @intFromEnum(vertexBuffer.attributes[0].format), @intFromEnum(vertexBuffer.attributes[1].format)});
    return .{ .handle = pipeline };
}
