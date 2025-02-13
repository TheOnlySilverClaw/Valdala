const webgpu = @import("webgpu");

const Self = @This();

pub fn createLinearClamped(device: webgpu.Device) webgpu.Sampler {

    const descriptor = webgpu.SamplerDescriptor {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .mag_filter = .linear,
        .min_filter = .linear,
        .mipmap_filter = .linear
    };

    return device.createSampler(&descriptor);
}