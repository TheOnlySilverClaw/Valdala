const shared = @import("shared.zig");
const buffer = @import("buffer.zig");
const bind_group = @import("bind_group.zig");
const query = @import("query.zig");
const compute_pipeline = @import("compute_pipeline.zig");


pub const ComputePassEncoder = *opaque {
    
    pub fn dispatchWorkgroups(encoder: ComputePassEncoder,
        count_x: u32, count_y: u32, count_z: u32) void {
        wgpuComputePassEncoderDispatchWorkgroups(encoder,
            count_x, count_y, count_z);
    }

    pub fn dispatchWorkgroupsIndirect(encoder: ComputePassEncoder,
        indirect_buffer: buffer.Buffer, offset: u64) void {
        wgpuComputePassEncoderDispatchWorkgroupsIndirect(encoder, indirect_buffer, offset);
    }

    pub fn end(encoder: ComputePassEncoder) void {
        wgpuComputePassEncoderEnd(encoder);
    }

    pub fn insertDebugMarker(encoder: ComputePassEncoder, marker_label: [*:0]const u8) void {
        wgpuComputePassEncoderInsertDebugMarker(encoder, marker_label);
    }

    pub fn popDebugGroup(encoder: ComputePassEncoder) void {
        wgpuComputePassEncoderPopDebugGroup(encoder);
    }

    pub fn pushDebugGroup(encoder: ComputePassEncoder, group_label: [*:0]const u8) void {
        wgpuComputePassEncoderPushDebugGroup(encoder, group_label);
    }

    pub fn setBindGroup(encoder: ComputePassEncoder,
        index: u32, group: bind_group.BindGroup, dynamic_offsets: ?[]const u32) void {
        wgpuComputePassEncoderSetBindGroup(encoder,
            index, group,
            if (dynamic_offsets) |offsets| @as(u32, @intCast(offsets.len)) else 0,
            if (dynamic_offsets) |offsets| offsets.ptr else null,
        );
    }

    pub fn setLabel(encoder: ComputePassEncoder, label: ?[*:0]const u8) void {
        wgpuComputePassEncoderSetLabel(encoder, label);
    }

    pub fn setPipeline(encoder: ComputePassEncoder, pipeline: compute_pipeline.ComputePipeline) void {
        wgpuComputePassEncoderSetPipeline(encoder, pipeline);
    }

    pub fn writeTimestamp(encoder: ComputePassEncoder,
        query_set: query.QuerySet, index: u32) void {
        wgpuComputePassEncoderWriteTimestamp(encoder, query_set, index);
    }

    pub fn reference(encoder: ComputePassEncoder) void {
        wgpuComputePassEncoderReference(encoder);
    }

    pub fn release(encoder: ComputePassEncoder) void {
        wgpuComputePassEncoderRelease(encoder);
    }
};

pub const ComputePassDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    timestamp_write_count: usize,
    timestamp_writes: ?[*]const ComputePassTimestampWrite,
};

pub const ComputePassTimestampWrite = extern struct {
    query_set: query.QuerySet,
    start: u32,
    end: u32,
};


extern fn wgpuComputePassEncoderDispatchWorkgroups(encoder: ComputePassEncoder,
    count_x: u32, count_y: u32, count_z: u32) void;

extern fn wgpuComputePassEncoderDispatchWorkgroupsIndirect(
    encoder: ComputePassEncoder, indirect_buffer: buffer.Buffer, offset: u64) void;

extern fn wgpuComputePassEncoderEnd(encoder: ComputePassEncoder) void;

extern fn wgpuComputePassEncoderInsertDebugMarker(
    encoder: ComputePassEncoder, label: [*:0]const u8) void;

extern fn wgpuComputePassEncoderPopDebugGroup(encoder: ComputePassEncoder) void;

extern fn wgpuComputePassEncoderPushDebugGroup(
    encoder: ComputePassEncoder, label: [*:0]const u8) void;

extern fn wgpuComputePassEncoderSetBindGroup(encoder: ComputePassEncoder,
    index: u32, group: bind_group.BindGroup,
    dynamic_offset_count: u32, dynamic_offsets: ?[*]const u32) void;

extern fn wgpuComputePassEncoderSetLabel(encoder: ComputePassEncoder, label: ?[*:0]const u8) void;

extern fn wgpuComputePassEncoderSetPipeline(encoder: ComputePassEncoder,
    pipeline: compute_pipeline.ComputePipeline) void;

extern fn wgpuComputePassEncoderWriteTimestamp(encoder: ComputePassEncoder,
    query_set: query.QuerySet, index: u32) void;

extern fn wgpuComputePassEncoderReference(encoder: ComputePassEncoder) void;

extern fn wgpuComputePassEncoderRelease(encoder: ComputePassEncoder) void;
