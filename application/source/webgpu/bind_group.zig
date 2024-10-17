const shared = @import("shared.zig");
const buffer = @import("buffer.zig");
const sampler = @import("sampler.zig");
const texture_view = @import("texture_view.zig");
const layout = @import("bind_group_layout.zig");

pub const BindGroup = *opaque {
    
    pub fn setLabel(bind_group: BindGroup, label: ?[*:0]const u8) void {
        wgpuBindGroupSetLabel(bind_group, label);
    }

    pub fn reference(bind_group: BindGroup) void {
        wgpuBindGroupReference(bind_group);
    }

    pub fn release(bind_group: BindGroup) void {
        wgpuBindGroupRelease(bind_group);
    }
};

pub const BindGroupEntry = extern struct {
    next: ?*const shared.ChainedStruct = null,
    binding: u32,
    buffer: ?buffer.Buffer = null,
    offset: u64 = 0,
    size: u64,
    sampler: ?sampler.Sampler = null,
    texture_view: ?texture_view.TextureView = null,
};

pub const BindGroupDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    layout: layout.BindGroupLayout,
    entry_count: usize,
    entries: ?[*]const BindGroupEntry,
};


extern fn wgpuBindGroupSetLabel(bind_group: BindGroup, label: ?[*:0]const u8) void;
extern fn wgpuBindGroupReference(bind_group: BindGroup) void;
extern fn wgpuBindGroupRelease(bind_group: BindGroup) void;