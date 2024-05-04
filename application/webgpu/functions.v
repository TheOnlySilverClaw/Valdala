module webgpu

fn C.wgpuGetVersion() int

fn C.wgpuCreateInstance(descriptor &C.WGPUInstanceDescriptor) WGPUInstance

fn C.wgpuInstanceRelease(instance WGPUInstance)

fn C.wgpuInstanceRequestAdapter(instance WGPUInstance, options &C.WGPURequestAdapterOptions, callback WGPURequestAdapterCallback, user_data voidptr)

fn C.wgpuAdapterRelease(adapter WGPUAdapter)

fn C.wgpuDeviceRelease(device WGPUDevice)

fn C.wgpuSurfaceRelease(adapter WGPUSurface)

fn C.wgpuAdapterRequestDevice(adapter WGPUAdapter, descriptor &C.WGPUDeviceDescriptor, callback WGPURequestDeviceCallback, user_data voidptr)

fn C.wgpuDeviceSetUncapturedErrorCallback(device WGPUDevice, callback WGPUErrorCallback, userdata voidptr)