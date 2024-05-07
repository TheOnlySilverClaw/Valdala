module binding

pub fn C.wgpuAdapterRequestDevice(adapter WGPUAdapter, descriptor &C.WGPUDeviceDescriptor, callback WGPURequestDeviceCallback, user_data voidptr)

pub fn C.wgpuAdapterRelease(adapter WGPUAdapter)