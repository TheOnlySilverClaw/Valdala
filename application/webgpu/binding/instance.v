module binding

pub fn C.wgpuCreateInstance(descriptor &C.WGPUInstanceDescriptor) WGPUInstance

pub fn C.wgpuInstanceRequestAdapter(instance WGPUInstance, options &C.WGPURequestAdapterOptions, callback WGPURequestAdapterCallback, user_data voidptr)

pub fn C.wgpuInstanceRelease(instance WGPUInstance)