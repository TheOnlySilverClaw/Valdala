const shared = @import("shared.zig");
const adapter = @import("adapter.zig");
const support = @import("support.zig");
const buffer = @import("buffer.zig");
const bind_group = @import("bind_group.zig");
const bind_group_layut = @import("bind_group_layout.zig");
const command_encoder = @import("command_encoder.zig");
const compute_pipeline = @import("compute_pipeline.zig");
const pipeline_layout = @import("pipeline_layout.zig");
const query = @import("query.zig");
const queue = @import("queue.zig");
const render_bundle = @import("render_bundle.zig");
const render_pipeline = @import("render_pipeline.zig");
const sampler = @import("sampler.zig");
const texture = @import("texture.zig");
const shader = @import("shader.zig");
const surface = @import("surface.zig");


pub const Device = *opaque {
    
    pub fn createBindGroup(device: Device,
        descriptor: *bind_group.BindGroupDescriptor) bind_group.BindGroup {
        return wgpuDeviceCreateBindGroup(device, descriptor);
    }

    pub fn createBindGroupLayout(device: Device,
        descriptor: *bind_group_layut.BindGroupLayoutDescriptor) bind_group_layut.BindGroupLayout {
        return wgpuDeviceCreateBindGroupLayout(device, descriptor);
    }

    pub fn createBuffer(device: Device, descriptor: *buffer.BufferDescriptor) buffer.Buffer {
        return wgpuDeviceCreateBuffer(device, descriptor);
    }

    pub fn createCommandEncoder(device: Device,
        descriptor: ?*command_encoder.CommandEncoderDescriptor) command_encoder.CommandEncoder {
        return wgpuDeviceCreateCommandEncoder(device, descriptor);
    }

    pub fn createComputePipeline(device: Device,
        descriptor: *compute_pipeline.ComputePipelineDescriptor) compute_pipeline.ComputePipeline {
        return wgpuDeviceCreateComputePipeline(device, descriptor);
    }

    pub fn createComputePipelineAsync(device: Device,
        descriptor: *compute_pipeline.ComputePipelineDescriptor,
        callback: compute_pipeline.CreateComputePipelineAsyncCallback,
        userdata: ?*anyopaque) void {
        wgpuDeviceCreateComputePipelineAsync(device, descriptor, callback, userdata);
    }

    pub fn createPipelineLayout(device: Device,
        descriptor: *pipeline_layout.PipelineLayoutDescriptor) pipeline_layout.PipelineLayout {
        return wgpuDeviceCreatePipelineLayout(device, descriptor);
    }

    pub fn createQuerySet(device: Device,
        descriptor: *query.QuerySetDescriptor) query.QuerySet {
        return wgpuDeviceCreateQuerySet(device, descriptor);
    }

    pub fn createRenderBundleEncoder(device: Device,
        descriptor: *render_bundle.RenderBundleEncoderDescriptor) render_bundle.RenderBundleEncoder {
        return wgpuDeviceCreateRenderBundleEncoder(device, descriptor);
    }

    pub fn createRenderPipeline(device: Device,
        descriptor: *render_pipeline.RenderPipelineDescriptor) render_pipeline.RenderPipeline {
        return wgpuDeviceCreateRenderPipeline(device, descriptor);
    }

    pub fn createRenderPipelineAsync(device: Device,
        descriptor: *render_pipeline.RenderPipelineDescriptor,
        callback: render_pipeline.CreateRenderPipelineAsyncCallback,
        userdata: ?*anyopaque) void {
        wgpuDeviceCreateRenderPipelineAsync(device, descriptor, callback, userdata);
    }

    pub fn createSampler(device: Device,
        descriptor: *sampler.SamplerDescriptor) sampler.Sampler {
        return wgpuDeviceCreateSampler(device, descriptor);
    }

    pub fn createShaderModule(device: Device,
        descriptor: *shader.ShaderModuleDescriptor) shader.ShaderModule {
        return wgpuDeviceCreateShaderModule(device, descriptor);
    }

    pub fn createTexture(device: Device,
        descriptor: *texture.TextureDescriptor) texture.Texture {
        return wgpuDeviceCreateTexture(device, descriptor);
    }

    pub fn destroy(device: Device) void {
        wgpuDeviceDestroy(device);
    }

    pub fn enumerateFeatures(device: Device, features: ?[*]support.FeatureName) usize {
        return wgpuDeviceEnumerateFeatures(device, features);
    }

    pub fn getLimits(device: Device, limits: *support.SupportedLimits) bool {
        return wgpuDeviceGetLimits(device, limits);
    }

    pub fn getQueue(device: Device) queue.Queue {
        return wgpuDeviceGetQueue(device);
    }

    pub fn hasFeature(device: Device, feature: support.FeatureName) bool {
        return wgpuDeviceHasFeature(device, feature);
    }

    pub fn getAdapter(device: Device) adapter.Adapter {
        return wgpuDeviceGetAdapter(device);
    }

    pub fn popErrorScope(device: Device, callback: shared.ErrorCallback, userdata: ?*anyopaque) bool {
        return wgpuDevicePopErrorScope(device, callback, userdata);
    }

    pub fn pushErrorScope(device: Device, filter: ErrorFilter) void {
        wgpuDevicePushErrorScope(device, filter);
    }

    pub fn setDeviceLostCallback(device: Device,
        callback: DeviceLostCallback, userdata: ?*anyopaque) void {
        wgpuDeviceSetDeviceLostCallback(device, callback, userdata);
    }

    pub fn setLabel(device: Device, label: ?[*:0]const u8) void {
        wgpuDeviceSetLabel(device, label);
    }

    pub fn setUncapturedErrorCallback(device: Device,
        callback: shared.ErrorCallback, userdata: ?*anyopaque) void {
        wgpuDeviceSetUncapturedErrorCallback(device, callback, userdata);
    }

    pub fn reference(device: Device) void {
        wgpuDeviceReference(device);
    }

    pub fn release(device: Device) void {
        wgpuDeviceRelease(device);
    }
};

pub const CreatePipelineAsyncStatus = enum(u32) {
    success,
    validation_error,
    internal_error,
    device_lost,
    device_destroyed,
    unknown
};

pub const DeviceDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    required_features_count: usize = 0,
    required_features: ?[*]const support.FeatureName = null,
    required_limits: ?[*]const support.RequiredLimits = null,
    default_queue: queue.QueueDescriptor = .{},
    device_lost_callback: ?DeviceLostCallback = null,
    device_lost_user_data: ?*anyopaque = null,
};

pub const DeviceLostCallback = *const fn (
    reason: DeviceLostReason,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque
) callconv(.C) void;

pub const DeviceLostReason = enum(u32) {
    undefined,
    destroyed
};

pub const ErrorFilter = enum(u32) {
    validation,
    out_of_memory,
    internal
};


extern fn wgpuDeviceCreateBindGroup(device: Device,
    descriptor: *const bind_group.BindGroupDescriptor) bind_group.BindGroup;

extern fn wgpuDeviceCreateBindGroupLayout(device: Device,
    descriptor: *const bind_group_layut.BindGroupLayoutDescriptor) bind_group_layut.BindGroupLayout;

extern fn wgpuDeviceCreateCommandEncoder(device: Device,
    descriptor: ?*const command_encoder.CommandEncoderDescriptor) command_encoder.CommandEncoder;

extern fn wgpuDeviceCreateBuffer(device: Device,
    descriptor: *const buffer.BufferDescriptor) buffer.Buffer;

extern fn wgpuDeviceCreateComputePipeline(device: Device,
    descriptor: *const compute_pipeline.ComputePipelineDescriptor) compute_pipeline.ComputePipeline;

extern fn wgpuDeviceCreateComputePipelineAsync(device: Device,
    descriptor: *const compute_pipeline.ComputePipelineDescriptor,
    callback: compute_pipeline.CreateComputePipelineAsyncCallback,
    userdata: ?*anyopaque) void;

extern fn wgpuDeviceCreatePipelineLayout(device: Device,
    descriptor: *const pipeline_layout.PipelineLayoutDescriptor) pipeline_layout.PipelineLayout;

extern fn wgpuDeviceCreateQuerySet(device: Device,
    descriptor: *const query.QuerySetDescriptor) query.QuerySet;

extern fn wgpuDeviceCreateRenderBundleEncoder(device: Device,
    descriptor: *const render_bundle.RenderBundleEncoderDescriptor) render_bundle.RenderBundleEncoder;

extern fn wgpuDeviceCreateRenderPipeline(device: Device,
    descriptor: *const render_pipeline.RenderPipelineDescriptor) render_pipeline.RenderPipeline;

extern fn wgpuDeviceCreateRenderPipelineAsync(device: Device,
    descriptor: *const render_pipeline.RenderPipelineDescriptor,
    callback: render_pipeline.CreateRenderPipelineAsyncCallback,
    userdata: ?*anyopaque) void;

extern fn wgpuDeviceCreateSampler(device: Device,
    descriptor: *const sampler.SamplerDescriptor) sampler.Sampler;

extern fn wgpuDeviceCreateShaderModule(device: Device,
    descriptor: *const shader.ShaderModuleDescriptor) shader.ShaderModule;

extern fn wgpuDeviceCreateTexture(device: Device,
    descriptor: *const texture.TextureDescriptor) texture.Texture;

extern fn wgpuDeviceDestroy(device: Device) void;

extern fn wgpuDeviceEnumerateFeatures(device: Device, features: ?[*]support.FeatureName) usize;

extern fn wgpuDeviceGetLimits(device: Device, limits: *support.SupportedLimits) bool;

extern fn wgpuDeviceGetQueue(device: Device) queue.Queue;

extern fn wgpuDeviceHasFeature(device: Device, feature: support.FeatureName) bool;

extern fn wgpuDeviceGetAdapter(device: Device) adapter.Adapter;

extern fn wgpuDevicePopErrorScope(device: Device, callback: shared.ErrorCallback, userdata: ?*anyopaque) bool;

extern fn wgpuDevicePushErrorScope(device: Device, filter: ErrorFilter) void;

extern fn wgpuDeviceSetDeviceLostCallback(device: Device,
    callback: DeviceLostCallback, userdata: ?*anyopaque) void;

extern fn wgpuDeviceSetLabel(device: Device, label: ?[*:0]const u8) void;

extern fn wgpuDeviceSetUncapturedErrorCallback(device: Device,
    callback: shared.ErrorCallback, userdata: ?*anyopaque) void;

extern fn wgpuDeviceReference(device: Device) void;

extern fn wgpuDeviceRelease(device: Device) void;