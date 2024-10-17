const shared = @import("shared.zig");

pub const RenderBundle = *opaque {
    
    pub fn setLabel(bundle: RenderBundle, label: ?[*:0]const u8) void {
        wgpuRenderBundleSetLabel(bundle, label);
    }

    pub fn reference(bundle: RenderBundle) void {
        wgpuRenderBundleReference(bundle);
    }

    pub fn release(bundle: RenderBundle) void {
        wgpuRenderBundleRelease(bundle);
    }
};

pub const RenderBundleDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null
};


extern fn wgpuRenderBundleSetLabel(bundle: RenderBundle, label: ?[*:0]const u8) void;

extern fn wgpuRenderBundleReference(bundle: RenderBundle) void;

extern fn wgpuRenderBundleRelease(bundle: RenderBundle) void;