const webgpu = @import("webgpu");

pub fn load(comptime name: []const u8, device: *webgpu.Device) *webgpu.ShaderModule {

    const source = @embedFile(name ++ ".wgsl");

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