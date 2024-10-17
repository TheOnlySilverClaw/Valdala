const shared = @import("shared.zig");
const layout = @import("pipeline_layout.zig");
const shader = @import("shader.zig");
const device = @import("device.zig");
const bind_group_layout = @import("bind_group_layout.zig");

pub const ComputePipeline = *opaque {

    pub fn getBindGroupLayout(pipeline: ComputePipeline, index: u32) bind_group_layout.BindGroupLayout {
        return wgpuComputePipelineGetBindGroupLayout(pipeline, index);
    }

    pub fn setLabel(pipeline: ComputePipeline, label: ?[*:0]const u8) void {
        wgpuComputePipelineSetLabel(pipeline, label);
    }

    pub fn reference(pipeline: ComputePipeline) void {
        wgpuComputePipelineReference(pipeline);
    }

    pub fn release(pipeline: ComputePipeline) void {
        wgpuComputePipelineRelease(pipeline);
    }
};

pub const CreateComputePipelineAsyncCallback = *const fn (
    status: device.CreatePipelineAsyncStatus,
    pipeline: ComputePipeline,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque,
) callconv(.C) void;

pub const ComputePipelineDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    layout: ?layout.PipelineLayout = null,
    compute: ProgrammableStageDescriptor
};

pub const ProgrammableStageDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    module: shader.ShaderModule,
    entry_point: [*:0]const u8,
    constant_count: usize = 0,
    constants: ?[*]const shared.ConstantEntry = null,
};


extern fn wgpuComputePipelineGetBindGroupLayout(pipeline: ComputePipeline,
    index: u32) bind_group_layout.BindGroupLayout;

extern fn wgpuComputePipelineSetLabel(pipeline: ComputePipeline, label: ?[*:0]const u8) void;

extern fn wgpuComputePipelineReference(pipeline: ComputePipeline) void;

extern fn wgpuComputePipelineRelease(pipeline: ComputePipeline) void;
