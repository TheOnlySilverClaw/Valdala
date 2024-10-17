const shared = @import("shared.zig");

pub const QuerySet = *opaque {
    
    pub fn destroy(query_set: QuerySet) void {
        wgpuQuerySetDestroy(query_set);
    }

    pub fn setLabel(query_set: QuerySet, label: ?[*:0]const u8) void {
        wgpuQuerySetSetLabel(query_set, label);
    }

    pub fn reference(query_set: QuerySet) void {
        wgpuQuerySetReference(query_set);
    }

    pub fn release(query_set: QuerySet) void {
        wgpuQuerySetRelease(query_set);
    }
};

pub const PipelineStatisticName = enum(u32) {
    vertex_shader_invocations,
    clipper_invocations,
    clipper_primitives_out,
    fragment_shader_invocations,
    compute_shader_invocations,
};

pub const QueryType = enum(u32) {
    occlusion,
    pipeline_statistics,
    timestamp
};

pub const QuerySetDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    query_type: QueryType,
    count: u32,
    pipeline_statistics: ?[*]const PipelineStatisticName,
    pipeline_statistics_count: usize,
};


extern fn wgpuQuerySetDestroy(query_set: QuerySet) void;

extern fn wgpuQuerySetSetLabel(query_set: QuerySet, label: ?[*:0]const u8) void;

extern fn wgpuQuerySetReference(query_set: QuerySet) void;

extern fn wgpuQuerySetRelease(query_set: QuerySet) void;