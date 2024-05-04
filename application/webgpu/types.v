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
	undefined        = 0
	low_power        = 1
	high_performance = 2
	// https://github.com/vlang/v/issues/19315
	// force32         = 0x7FFFFFFF
}

enum WGPUBackendType {
	undefined = 0
	null      = 1
	webgpu    = 2
	d3d11     = 3
	d3d12     = 4
	metal     = 5
	vulkan    = 6
	opengl    = 7
	opengles  = 8
	// force32   = 0x7FFFFFFF
}

enum WGPURequestAdapterStatus {
	success     = 0
	unavailable = 1
	error       = 2
	unknown     = 3
	// force32     = 2147483647
}

enum WGPURequestDeviceStatus {
	success = 0
	error   = 1
	unknown = 2
	// force32   = 0x7FFFFFFF
}

enum WGPUFeatureName {
	undefined               = 0
	depth_clip_control        = 1
	depth32_floatstencil8    = 2
	timestamp_query          = 3
	texture_compression_bc    = 4
	texture_compression_etc2  = 5
	texture_compression_astc  = 6
	indirect_first_instance   = 7
	shaderf16               = 8
	rg11b10_ufloat_renderable = 9
	bgra8_unorm_storage       = 10
	float32_filterable       = 11
	// force32   = 0x7FFFFFFF
}

enum WGPUDeviceLostReason {
	undefined = 0
	destroyed = 1
	// force32   = 0x7FFFFFFF
}

enum WGPUErrorType {
	no_error     = 0
	validation  = 1
	out_of_memory = 2
	internal    = 3
	unknown     = 4
	device_lost  = 5
	// force32   = 0x7FFFFFFF
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

struct C.WGPURequiredLimits {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	limits      C.WGPULimits
}

struct C.WGPULimits {
	maxTextureDimension1D                     u32
	maxTextureDimension2D                     u32
	maxTextureDimension3D                     u32
	maxTextureArrayLayers                     u32
	maxBindGroups                             u32
	maxBindGroupsPlusVertexBuffers            u32
	maxBindingsPerBindGroup                   u32
	maxDynamicUniformBuffersPerPipelineLayout u32
	maxDynamicStorageBuffersPerPipelineLayout u32
	maxSampledTexturesPerShaderStage          u32
	maxSamplersPerShaderStage                 u32
	maxStorageBuffersPerShaderStage           u32
	maxStorageTexturesPerShaderStage          u32
	maxUniformBuffersPerShaderStage           u32
	maxUniformBufferBindingSize               u64
	maxStorageBufferBindingSize               u64
	minUniformBufferOffsetAlignment           u32
	minStorageBufferOffsetAlignment           u32
	maxVertexBuffers                          u32
	maxBufferSize                             u64
	maxVertexAttributes                       u32
	maxVertexBufferArrayStride                u32
	maxInterStageShaderComponents             u32
	maxInterStageShaderVariables              u32
	maxColorAttachments                       u32
	maxColorAttachmentBytesPerSample          u32
	maxComputeWorkgroupStorageSize            u32
	maxComputeInvocationsPerWorkgroup         u32
	maxComputeWorkgroupSizeX                  u32
	maxComputeWorkgroupSizeY                  u32
	maxComputeWorkgroupSizeZ                  u32
	maxComputeWorkgroupsPerDimension          u32
}

struct C.WGPUQueueDescriptor {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

struct C.WGPUDeviceDescriptor {
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	label                &char
	requiredFeatureCount usize
	requiredFeatures     &WGPUFeatureName
	requiredLimits       &C.WGPURequiredLimits
	defaultQueue         C.WGPUQueueDescriptor
	deviceLostCallback   WGPUDeviceLostCallback
	deviceLostUserdata   voidptr
}


type WGPURequestAdapterCallback = fn (WGPURequestAdapterStatus, WGPUAdapter, &char, voidptr)
type WGPURequestDeviceCallback = fn (WGPURequestDeviceStatus, WGPUDevice, &char, voidptr)
type WGPUDeviceLostCallback = fn (WGPUDeviceLostReason, &char, voidptr)
type WGPUErrorCallback = fn (WGPUErrorType, &char, voidptr)
