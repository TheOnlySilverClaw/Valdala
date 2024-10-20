const shared = @import("shared.zig");
const adapter = @import("adapter.zig");
const surface = @import("surface.zig");


pub fn create(descriptor: ?*const InstanceDescriptor) Instance {
    return wgpuCreateInstance(descriptor);
}

pub const Instance = *opaque {

    pub fn createSurface(instance: Instance,
        descriptor: *const surface.SurfaceDescriptor) surface.Surface {
        return wgpuInstanceCreateSurface(instance, descriptor);
    }

    pub fn requestAdapterAsync(instance: Instance,
        options: *const RequestAdapterOptions, callback: RequestAdapterCallback,
        userdata: ?*anyopaque) void {
        wgpuInstanceRequestAdapter(instance, options, callback, userdata);
    }

    pub fn requestAdapter(instance: Instance, options: *const RequestAdapterOptions) RequestAdapterResult {

        var result = RequestAdapterResult {
            .status = .unknown,
            .adapter = null,
            .message = null
        };

        wgpuInstanceRequestAdapter(instance, options, adapterCallback, @ptrCast(&result));
        
        return result;
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
    compatible_surface: ?surface.Surface,
    power_preference: adapter.PowerPreference,
    backend_type: adapter.BackendType = .undefined,
    force_fallback_adapter: bool = false,
};

pub const RequestAdapterResult = struct {
    adapter: ?adapter.Adapter,
    message: ?[*:0]const u8,
    status: RequestAdapterStatus
};

pub const RequestAdapterStatus = enum(u32) {
    success,
    unavailable,
    failure,
    unknown
};

fn adapterCallback(status: RequestAdapterStatus, received: adapter.Adapter, message: ?[*:0]const u8, userdata: ?shared.UserData) callconv(.C) void {
    
    var result = @as(*RequestAdapterResult, @alignCast(@ptrCast(userdata)));
    result.status = status;
    result.message = message;
    result.adapter = received;
}


extern fn wgpuCreateInstance(descriptor: ?* const InstanceDescriptor) Instance;

extern fn wgpuInstanceCreateSurface(instance: Instance,
    descriptor: *const surface.SurfaceDescriptor) surface.Surface;

extern fn wgpuInstanceRequestAdapter(instance: Instance,
    options: *const RequestAdapterOptions, callback: RequestAdapterCallback, userdata: ?shared.UserData) void;

extern fn wgpuInstanceReference(instance: Instance) void;

extern fn wgpuInstanceRelease(instance: Instance) void;