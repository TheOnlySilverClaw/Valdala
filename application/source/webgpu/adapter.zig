const device = @import("device.zig");
const shared = @import("shared.zig");
const support = @import("support.zig");
const surface = @import("surface.zig");

pub const Adapter = *opaque {

    pub fn enumerateFeatures(adapter: Adapter, features: ?[*]support.FeatureName) usize {
        return wgpuAdapterEnumerateFeatures(adapter, features);
    }

    pub fn getLimits(adapter: Adapter, limits: *support.SupportedLimits) bool {
        return wgpuAdapterGetLimits(adapter, limits);
    }

    pub fn getInfo(adapter: Adapter, properties: *AdapterInfo) void {
        wgpuAdapterGetInfo(adapter, properties);
    }

    pub fn hasFeature(adapter: Adapter, feature: support.FeatureName) bool {
        return wgpuAdapterHasFeature(adapter, feature);
    }

    pub fn requestDevice(adapter: Adapter, descriptor: *device.DeviceDescriptor,
        callback: device.RequestDeviceCallback, userdata: ?*anyopaque) void {
        wgpuAdapterRequestDevice(adapter, descriptor, callback, userdata);
    }

    pub fn reference(adapter: Adapter) void {
        wgpuAdapterReference(adapter);
    }

    pub fn release(adapter: Adapter) void {
        wgpuAdapterRelease(adapter);
    }
};

const AdapterError = error{REQUEST_FAILED};

pub const AdapterInfo = extern struct {
    next: ?*shared.ChainedStructOut = null,
    vendor: [*:0]const u8,
    architecture: [*:0]const u8,
    device: [*:0]const u8,
    description: [*:0]const u8,
    backend_type: BackendType,
    adapter_type: AdapterType,
    vendor_id: u32,
    device_id: u32,
};

pub const AdapterType = enum(u32) {
    discrete_gpu,
    integrated_gpu,
    cpu,
    unknown,
};

pub const BackendType = enum(u32) {
    undefined,
    null,
    webgpu,
    d3d11,
    d3d12,
    metal,
    vulkan,
    opengl,
    opengles,
};

pub const PowerPreference = enum(u32) {
    undefined,
    low_power,
    high_performance
};

pub const RequestDeviceCallback = *const fn (
    status: RequestDeviceStatus,
    device: device.Device,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque,
) callconv(.C) void;

pub const RequestDeviceStatus = enum(u32) {
    success,
    failure,
    unknown
};

extern fn wgpuAdapterCreateDevice(adapter: Adapter, descriptor: *const device.DeviceDescriptor) device.Device;

extern fn wgpuAdapterEnumerateFeatures(adapter: Adapter, features: ?[*]support.FeatureName) usize;

extern fn wgpuAdapterGetLimits(adapter: Adapter, limits: *support.SupportedLimits) bool;

extern fn wgpuAdapterGetInfo(adapter: Adapter, properties: *AdapterInfo) void;

extern fn wgpuAdapterHasFeature(adapter: Adapter, feature: support.FeatureName) bool;

extern fn wgpuAdapterRequestDevice(adapter: Adapter, descriptor: *const device.DeviceDescriptor, callback: RequestDeviceCallback, userdata: ?*anyopaque) void;

extern fn wgpuAdapterReference(adapter: Adapter) void;

extern fn wgpuAdapterRelease(adapter: Adapter) void;
