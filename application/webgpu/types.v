module webgpu

type WGPUBool = int

type WGPUAdapter = voidptr
type WGPUBindGroup = voidptr
type WGPUBindGroupLayout = voidptr
type WGPUBuffer = voidptr
type WGPUCommandBuffer = voidptr
type WGPUCommandEncoder = voidptr
type WGPUComputePassEncoder = voidptr
type WGPUComputePipeline = voidptr
type WGPUDevice = voidptr
type WGPUInstance = voidptr
type WGPUPipelineLayout = voidptr
type WGPUQuerySet = voidptr
type WGPUQueue = voidptr
type WGPURenderBundle = voidptr
type WGPURenderBundleEncoder = voidptr
type WGPURenderPassEncoder = voidptr
type WGPURenderPipeline = voidptr
type WGPUSampler = voidptr
type WGPUShaderModule = voidptr
type WGPUSurface = voidptr
type WGPUTexture = voidptr
type WGPUTextureView = voidptr

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
