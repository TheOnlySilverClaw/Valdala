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

enum WGPURequestDeviceStatus {
	success = 0x00000000
	error   = 0x00000001
	unknown = 0x00000002
	// force32   = 0x7FFFFFFF
}

enum WGPUFeatureName {
	undefined               = 0x00000000
	depth_clip_control        = 0x00000001
	depth32_floatstencil8    = 0x00000002
	timestamp_query          = 0x00000003
	texture_compression_bc    = 0x00000004
	texture_compression_etc2  = 0x00000005
	texture_compression_astc  = 0x00000006
	indirect_first_instance   = 0x00000007
	shaderf16               = 0x00000008
	rg11b10_ufloat_renderable = 0x00000009
	bgra8_unorm_storage       = 0x000000010
	float32_filterable       = 0x000000011
	// force32   = 0x7FFFFFFF
}

enum WGPUDeviceLostReason {
	undefined = 0x00000000
	destroyed = 0x00000001
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
