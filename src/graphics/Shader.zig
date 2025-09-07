const webgpu = @import("webgpu");

pub fn load(comptime source: []const u8, device: *webgpu.Device, name: []const u8) *webgpu.ShaderModule {

    const source_descriptor = webgpu.ShaderSourceWGSL {
        .chain = .{ .type = .shader_source_wgsl },
        .code = webgpu.StringView.sized(source)
    };

    const descriptor = webgpu.ShaderModuleDescriptor {
        .next = &source_descriptor.chain,
        .label = webgpu.StringView.sized(name)
    };

    return device.createShaderModule(&descriptor);
}