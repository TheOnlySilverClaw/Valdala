const shared = @import("shared.zig");
const adapter = @import("adapter.zig");
const surface = @import("surface.zig");


pub fn createInstance(descriptor: ?*const InstanceDescriptor) Instance {
    return wgpuCreateInstance(descriptor);
}

pub const Instance = *opaque {

    pub fn createSurface(instance: Instance,
        descriptor: *surface.SurfaceDescriptor) surface.Surface {
        return wgpuInstanceCreateSurface(instance, descriptor);
    }

    pub fn requestAdapter(instance: Instance,
        options: RequestAdapterOptions, callback: RequestAdapterCallback,
        userdata: ?*anyopaque) void {
        wgpuInstanceRequestAdapter(instance, &options, callback, userdata);
    }

    pub fn reference(instance: Instance) void {
        wgpuInstanceReference(instance);
    }

    pub fn release(instance: Instance) void {
        wgpuInstanceRelease(instance);
    }
};

pub const InstanceDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null
};

pub const RequestAdapterCallback = *const fn (
    status: RequestAdapterStatus,
    adapter: adapter.Adapter,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque
) callconv(.C) void;

pub const RequestAdapterOptions = extern struct {
    next: ?*const shared.ChainedStruct = null,
    compatible_surface: ?surface.Surface = null,
    power_preference: adapter.PowerPreference,
    backend_type: adapter.BackendType = .undefined,
    force_fallback_adapter: bool = false,
    compatibility_mode: bool = false,
};

pub const RequestAdapterStatus = enum(u32) {
    success,
    unavailable,
    failure,
    unknown
};


extern fn wgpuCreateInstance(descriptor: ?* const InstanceDescriptor) Instance;

extern fn wgpuInstanceCreateSurface(instance: Instance,
    descriptor: *const surface.SurfaceDescriptor) surface.Surface;

extern fn wgpuInstanceRequestAdapter(instance: Instance,
    options: *const RequestAdapterOptions, callback: RequestAdapterCallback, userdata: ?*anyopaque) void;

extern fn wgpuInstanceReference(instance: Instance) void;

extern fn wgpuInstanceRelease(instance: Instance) void;