const shared = @import("shared.zig");
const bind_group_layout = @import("bind_group_layout.zig");

pub const PipelineLayout = *opaque {
    
    pub fn setLabel(layout: PipelineLayout, label: ?[*:0]const u8) void {
        wgpuPipelineLayoutSetLabel(layout, label);
    }

    pub fn reference(layout: PipelineLayout) void {
        wgpuPipelineLayoutReference(layout);
    }

    pub fn release(layout: PipelineLayout) void {
        wgpuPipelineLayoutRelease(layout);
    }
};

pub const PipelineLayoutDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    bind_group_layout_count: usize,
    bind_group_layouts: ?[*]const bind_group_layout.BindGroupLayout,
};


extern fn wgpuPipelineLayoutSetLabel(layout: PipelineLayout, label: ?[*:0]const u8) void;

extern fn wgpuPipelineLayoutReference(layout: PipelineLayout) void;

extern fn wgpuPipelineLayoutRelease(layout: PipelineLayout) void;
