const shared = @import("shared.zig");
const texture = @import("texture.zig");


pub const Sampler = *opaque {

    pub fn setLabel(sampler: Sampler, label: ?[*:0]const u8) void {
        wgpuSamplerSetLabel(sampler, label);
    }

    pub fn reference(sampler: Sampler) void {
        wgpuSamplerReference(sampler);
    }

    pub fn release(sampler: Sampler) void {
        wgpuSamplerRelease(sampler);
    }
};

pub const AddressMode = enum(u32) {
    repeat,
    mirror_repeat,
    clamp_to_edge,
};

pub const FilterMode = enum(u32) {
    nearest,
    linear,
};

// as long as it has the same values
pub const MipmapFilterMode = FilterMode;

pub const SamplerDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    address_mode_u: AddressMode,
    address_mode_v: AddressMode,
    address_mode_w: AddressMode,
    mag_filter: FilterMode,
    min_filter: FilterMode,
    mipmap_filter: MipmapFilterMode,
    lod_min_clamp: f32 = 0.0,
    lod_max_clamp: f32 = 32.0,
    compare: shared.CompareFunction = .undefined,
    max_anisotropy: u16 = 1,
};


extern fn wgpuSamplerSetLabel(sampler: Sampler, label: ?[*:0]const u8) void;

extern fn wgpuSamplerReference(sampler: Sampler) void;

extern fn wgpuSamplerRelease(sampler: Sampler) void;
