module webgpu

type WGPUBool = int

pub type WGPUAdapter = voidptr
pub type WGPUBindGroup = voidptr
pub type WGPUBindGroupLayout = voidptr
pub type WGPUBuffer = voidptr
pub type WGPUCommandBuffer = voidptr
pub type WGPUCommandEncoder = voidptr
pub type WGPUComputePassEncoder = voidptr
pub type WGPUComputePipeline = voidptr
pub type WGPUDevice = voidptr
pub type WGPUInstance = voidptr
pub type WGPUPipelineLayout = voidptr
pub type WGPUQuerySet = voidptr
pub type WGPUQueue = voidptr
pub type WGPURenderBundle = voidptr
pub type WGPURenderBundleEncoder = voidptr
pub type WGPURenderPassEncoder = voidptr
pub type WGPURenderPipeline = voidptr
pub type WGPUSampler = voidptr
pub type WGPUShaderModule = voidptr
pub type WGPUSurface = voidptr
pub type WGPUTexture = voidptr
pub type WGPUTextureView = voidptr

enum WGPUPowerPreference {
	undefined        = 0x00000000
	low_power        = 0x00000001
	high_performance = 0x00000002
	// https://github.com/vlang/v/issues/19315
	// force32         = 0x7FFFFFFF
}

enum WGPUBackendType {
	undefined = 0x00000000
	null      = 0x00000001
	webgpu    = 0x00000002
	d3d11     = 0x00000003
	d3d12     = 0x00000004
	metal     = 0x00000005
	vulkan    = 0x00000006
	opengl    = 0x00000007
	opengles  = 0x00000008
	// force32   = 0x7FFFFFFF
}

enum WGPURequestAdapterStatus {
	success     = 0x00000000
	unavailable = 0x00000001
	error       = 0x00000002
	unknown     = 0x00000003
	// force32     = 2147483647
}

struct C.WGPUChainedStruct {
	next &C.WGPUChainedStruct = unsafe { nil }
}

struct C.WGPUInstanceDescriptor {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
}

struct C.WGPURequestAdapterOptions {
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	compatibleSurface    WGPUSurface
	powerPreference      WGPUPowerPreference
	backendType          WGPUBackendType
	forceFallbackAdapter WGPUBool
}

type WGPURequestAdapterCallback = fn (WGPURequestAdapterStatus, WGPUAdapter, &char, voidptr)
