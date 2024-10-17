const shared = @import("shared.zig");

pub const view = @import("texture_view.zig");

pub const Texture = *opaque {

    pub fn createView(texture: Texture, descriptor: *view.TextureViewDescriptor) view.TextureView {
        return wgpuTextureCreateView(texture, descriptor);
    }

    pub fn destroy(texture: Texture) void {
        wgpuTextureDestroy(texture);
    }

    pub fn setLabel(texture: Texture, label: ?[*:0]const u8) void {
        wgpuTextureSetLabel(texture, label);
    }

    pub fn reference(texture: Texture) void {
        wgpuTextureReference(texture);
    }

    pub fn release(texture: Texture) void {
        wgpuTextureRelease(texture);
    }
};


pub const AddressMode = enum(u32) {
    repeat,
    mirror_repeat,
    clamp_to_edge,
};

pub const AlphaMode = enum(u32) {
    premultiplied,
    unpremultiplied,
    opaque_,
};

pub const TextureAspect = enum(u32) {
    all,
    stencil_only,
    depth_only
};

pub const TextureDataLayout = extern struct {
    next: ?*const shared.ChainedStruct = null,
    offset: u64 = 0,
    bytes_per_row: u32,
    rows_per_image: u32
};

pub const TextureDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    usage: TextureUsage,
    dimension: TextureDimension = .tdim_2d,
    size: shared.Extent3D,
    format: TextureFormat,
    mip_level_count: u32 = 1,
    sample_count: u32 = 1,
    view_format_count: usize = 0,
    view_formats: ?[*]const TextureFormat = null,
};


pub const TextureDimension = enum(u32) {
    _1d,
    _2d,
    _3d,
};

pub const TextureFormat = enum(u32) {
    undefined,
    r8_unorm,
    r8_snorm,
    r8_uint,
    r8_sint,
    r16_uint,
    r16_sint,
    r16_float,
    rg8_unorm,
    rg8_snorm,
    rg8_uint,
    rg8_sint,
    r32_float,
    r32_uint,
    r32_sint,
    rg16_uint,
    rg16_sint,
    rg16_float,
    rgba8_unorm,
    rgba8_unorm_srgb,
    rgba8_snorm,
    rgba8_uint,
    rgba8_sint,
    bgra8_unorm,
    bgra8_unorm_srgb,
    rgb10_a2_unorm,
    rg11_b10_ufloat,
    rgb9_e5_ufloat,
    rg32_float,
    rg32_uint,
    rg32_sint,
    rgba16_uint,
    rgba16_sint,
    rgba16_float,
    rgba32_float,
    rgba32_uint,
    rgba32_sint,
    stencil8,
    depth16_unorm,
    depth24_plus,
    depth24_plus_stencil8,
    depth32_float,
    depth32_float_stencil8,
    bc1_rgba_unorm,
    bc1_rgba_unorm_srgb,
    bc2_rgba_unorm,
    bc2_rgba_unorm_srgb,
    bc3_rgba_unorm,
    bc3_rgba_unorm_srgb,
    bc4_runorm,
    bc4_rsnorm,
    bc5_rg_unorm,
    bc5_rg_snorm,
    bc6_hrgb_ufloat,
    bc6_hrgb_float,
    bc7_rgba_unorm,
    bc7_rgba_unorm_srgb,
    etc2_rgb8_unorm,
    etc2_rgb8_unorm_srgb,
    etc2_rgb8_a1_unorm,
    etc2_rgb8_a1_unorm_srgb,
    etc2_rgba8_unorm,
    etc2_rgba8_unorm_srgb,
    eacr11_unorm,
    eacr11_snorm,
    eacrg11_unorm,
    eacrg11_snorm,
    astc4x4_unorm,
    astc4x4_unorm_srgb,
    astc5x4_unorm,
    astc5x4_unorm_srgb,
    astc5x5_unorm,
    astc5x5_unorm_srgb,
    astc6x5_unorm,
    astc6x5_unorm_srgb,
    astc6x6_unorm,
    astc6x6_unorm_srgb,
    astc8x5_unorm,
    astc8x5_unorm_srgb,
    astc8x6_unorm,
    astc8x6_unorm_srgb,
    astc8x8_unorm,
    astc8x8_unorm_srgb,
    astc10x5_unorm,
    astc10x5_unorm_srgb,
    astc10x6_unorm,
    astc10x6_unorm_srgb,
    astc10x8_unorm,
    astc10x8_unorm_srgb,
    astc10x10_unorm,
    astc10x10_unorm_srgb,
    astc12x10_unorm,
    astc12x10_unorm_srgb,
    astc12x12_unorm,
    astc12x12_unorm_srgb
};

pub const TextureUsage = packed struct(u32) {
    copy_src: bool = false,
    copy_dst: bool = false,
    texture_binding: bool = false,
    storage_binding: bool = false,
    render_attachment: bool = false,
    transient_attachment: bool = false,
    _padding: u26 = 0,
};


extern fn wgpuTextureCreateView(texture: Texture, descriptor: *const view.TextureViewDescriptor) view.TextureView;

extern fn wgpuTextureDestroy(texture: Texture) void;

extern fn wgpuTextureSetLabel(texture: Texture, label: ?[*:0]const u8) void;

extern fn wgpuTextureReference(texture: Texture) void;

extern fn wgpuTextureRelease(texture: Texture) void;