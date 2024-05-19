module binding

pub fn C.wgpuAdapterRequestDevice(adapter WGPUAdapter, descriptor &C.WGPUDeviceDescriptor, callback WGPURequestDeviceCallback, user_data voidptr)

pub fn C.wgpuAdapterRelease(adapter WGPUAdapter)

pub type WGPUAdapter = voidptr

pub type WGPURequestAdapterCallback = fn (status WGPURequestAdapterStatus, adapter WGPUAdapter, message &char, user_data voidptr)

pub struct C.WGPURequestAdapterOptions {
pub:
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	compatibleSurface    WGPUSurface
	powerPreference      WGPUPowerPreference
	backendType          WGPUBackendType
	forceFallbackAdapter WGPUBool
}

pub enum WGPUPowerPreference {
	undefined        = 0
	low_power        = 1
	high_performance = 2
}

pub enum WGPUBackendType {
	undefined = 0
	null      = 1
	webgpu    = 2
	d3d11     = 3
	d3d12     = 4
	metal     = 5
	vulkan    = 6
	opengl    = 7
	opengles  = 8
}

pub enum WGPURequestAdapterStatus {
	success     = 0
	unavailable = 1
	error       = 2
	unknown     = 3
}
