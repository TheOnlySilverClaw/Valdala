const webgpu = @import("webgpu");

pub fn load(comptime source: []const u8, device: *webgpu.device.Device, name: []const u8) *webgpu.shader.ShaderModule {

    const source_descriptor = webgpu.shader.ShaderSourceWGSL {
        .chain = .{ .type = .shader_source_wgsl },
        .code = webgpu.StringView.sliced(source)
    };

    const descriptor = webgpu.shader.ShaderModuleDescriptor {
        .next = &source_descriptor.chain,
        .label = webgpu.StringView.sliced(name)
    };

    return device.createShaderModule(&descriptor);
}