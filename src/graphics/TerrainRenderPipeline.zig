const webgpu = @import("webgpu");

const Self = @This();


handle: *webgpu.RenderPipeline,

pub fn create(device: *webgpu.Device) !Self {

    const descriptor = webgpu.RenderPipelineDescriptor {
        .label = webgpu.StringView.sized("scene"),
        .depth_stencil = null,
    };

    const handle = device.createRenderPipeline(&descriptor);
    
    return .{
        .handle = handle
    };
}