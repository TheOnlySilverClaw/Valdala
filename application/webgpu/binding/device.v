module binding

pub fn C.wgpuDeviceGetQueue(device WGPUDevice) WGPUQueue

pub fn C.wgpuDeviceCreateShaderModule(device WGPUDevice, descriptor &C.WGPUShaderModuleDescriptor) WGPUShaderModule

pub fn C.wgpuDeviceCreateCommandEncoder(device WGPUDevice, descriptor &C.WGPUCommandEncoderDescriptor) WGPUCommandEncoder

pub fn C.wgpuDeviceCreateBindGroupLayout(device WGPUDevice, descriptor &C.WGPUBindGroupLayoutDescriptor) WGPUBindGroupLayout

pub fn C.wgpuDeviceCreateBindGroup(device WGPUDevice, descriptor &C.WGPUBindGroupDescriptor) WGPUBindGroup

pub fn C.wgpuDeviceCreatePipelineLayout(device WGPUDevice, descriptor &C.WGPUPipelineLayoutDescriptor) WGPUPipelineLayout

pub fn C.wgpuDeviceCreateBuffer(device WGPUDevice, descriptor &C.WGPUBufferDescriptor) WGPUBuffer

pub fn C.wgpuDeviceCreateTexture(device WGPUDevice, descriptor &C.WGPUTextureDescriptor) WGPUTexture

pub fn C.wgpuDeviceCreateSampler(device WGPUDevice, descriptor &C.WGPUSamplerDescriptor) WGPUSampler

pub fn C.wgpuDeviceCreateRenderPipeline(device WGPUDevice, descriptor &C.WGPURenderPipelineDescriptor) WGPURenderPipeline

pub fn C.wgpuDeviceSetUncapturedErrorCallback(device WGPUDevice, callback WGPUErrorCallback, userdata voidptr)

pub fn C.wgpuDeviceRelease(device WGPUDevice)

pub type WGPUDevice = voidptr

pub type WGPURequestDeviceCallback = fn (status WGPURequestDeviceStatus, device WGPUDevice, message &char, user_data voidptr)

pub type WGPUErrorCallback = fn (errorType WGPUErrorType, message &char, user_data voidptr)

pub type WGPUDeviceLostCallback = fn (reason WGPUDeviceLostReason, message &char, user_data voidptr)

pub struct C.WGPUDeviceDescriptor {
pub:
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	label                &char
	requiredFeatureCount usize
	requiredFeatures     &WGPUFeatureName
	requiredLimits       &C.WGPURequiredLimits
	defaultQueue         C.WGPUQueueDescriptor
	deviceLostCallback   WGPUDeviceLostCallback
	deviceLostUserdata   voidptr
}

pub struct C.WGPURequiredLimits {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	limits      C.WGPULimits
}

pub struct C.WGPULimits {
pub:
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

pub enum WGPUFeatureName {
	undefined                 = 0
	depth_clip_control        = 1
	depth32_floatstencil8     = 2
	timestamp_query           = 3
	texture_compression_bc    = 4
	texture_compression_etc2  = 5
	texture_compression_astc  = 6
	indirect_first_instance   = 7
	shader_f16                = 8
	rg11b10_ufloat_renderable = 9
	bgra8_unorm_storage       = 10
	float32_filterable        = 11
}

pub enum WGPURequestDeviceStatus {
	success = 0
	error   = 1
	unknown = 2
}

pub enum WGPUDeviceLostReason {
	undefined = 0
	destroyed = 1
}

pub enum WGPUErrorType {
	no_error      = 0
	validation    = 1
	out_of_memory = 2
	internal      = 3
	unknown       = 4
	device_lost   = 5
}
