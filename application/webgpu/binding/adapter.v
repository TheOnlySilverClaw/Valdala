module binding

pub struct C.WGPURequestAdapterOptions {
pub:
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	compatibleSurface    WGPUSurface
	powerPreference      WGPUPowerPreference
	backendType          WGPUBackendType
	forceFallbackAdapter WGPUBool
}

pub fn C.wgpuAdapterRequestDevice(adapter WGPUAdapter, descriptor &C.WGPUDeviceDescriptor, callback WGPURequestDeviceCallback, user_data voidptr)

pub fn C.wgpuAdapterRelease(adapter WGPUAdapter)
