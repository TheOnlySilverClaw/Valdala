const shared = @import("shared.zig");
const texture = @import("texture.zig");


pub const TextureView = *opaque {
    
    pub fn setLabel(texture_view: TextureView, label: ?[*:0]const u8) void {
        wgpuTextureViewSetLabel(texture_view, label);
    }

    pub fn reference(texture_view: TextureView) void {
        wgpuTextureViewReference(texture_view);
    }

    pub fn release(texture_view: TextureView) void {
        wgpuTextureViewRelease(texture_view);
    }
};


pub const TextureViewDimension = enum(u32) {
    undefined,
    @"1d",
    @"2d",
    @"2d_array",
    cube,
    cube_array,
    @"3d"
};

pub const TextureViewDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    format: texture.TextureFormat,
    dimension: TextureViewDimension,
    base_mip_level: u32 = 0,
    mip_level_count: u32 = 1,
    base_array_layer: u32 = 0,
    array_layer_count: u32 = 1,
    aspect: texture.TextureAspect = .all
};


extern fn wgpuTextureViewSetLabel(texture_view: TextureView, label: ?[*:0]const u8) void;

extern fn wgpuTextureViewReference(texture_view: TextureView) void;

extern fn wgpuTextureViewRelease(texture_view: TextureView) void;
