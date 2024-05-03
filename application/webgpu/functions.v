module webgpu

fn C.wgpuGetVersion() int

fn C.wgpuCreateInstance(descriptor &C.WGPUInstanceDescriptor) WGPUInstance

fn C.wgpuInstanceRelease(instance WGPUInstance)

fn C.wgpuInstanceRequestAdapter(instance WGPUInstance, options &C.WGPURequestAdapterOptions, callback WGPURequestAdapterCallback, user_data voidptr)

fn C.wgpuAdapterRelease(adapter WGPUAdapter)
