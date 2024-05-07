module binding


pub struct C.WGPUChainedStruct {
	pub:
	next &C.WGPUChainedStruct
	sType WGPUSType
}

pub struct C.WGPUChainedStructOut {
	pub:
	next  &C.WGPUChainedStructOut
	sType WGPUSType
}

pub struct C.WGPUInstanceDescriptor {
    pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
}

pub struct C.WGPURequestAdapterOptions {
	pub:
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	compatibleSurface    WGPUSurface
	powerPreference      WGPUPowerPreference
	backendType          WGPUBackendType
	forceFallbackAdapter WGPUBool
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

pub struct C.WGPUQueueDescriptor {
	pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

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

pub struct C.WGPUColor {
	pub:
	r f64
	g f64
	b f64
	a f64
}

pub struct C.WGPUCommandBufferDescriptor {
	pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

pub struct C.WGPUCommandEncoderDescriptor {
	pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

pub struct C.WGPURenderPassColorAttachment {
	pub:
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	view          WGPUTextureView
	resolveTarget WGPUTextureView
	loadOp        WGPULoadOp
	storeOp       WGPUStoreOp
	clearValue    C.WGPUColor
}

pub struct C.WGPURenderPassTimestampWrites {
	pub:
	querySet                  WGPUQuerySet
	beginningOfPassWriteIndex u32
	endOfPassWriteIndex       u32
}

pub struct C.WGPURenderPassDescriptor {
	pub:
	nextInChain            &C.WGPUChainedStruct = unsafe { nil }
	label                  &char
	colorAttachmentCount   usize
	colorAttachments       &C.WGPURenderPassColorAttachment
	depthStencilAttachment &C.WGPURenderPassDepthStencilAttachment
	occlusionQuerySet      WGPUQuerySet
	timestampWrites        &C.WGPURenderPassTimestampWrites
}

pub struct C.WGPUSurfaceConfiguration {
	pub:
	nextInChain     &C.WGPUChainedStruct = unsafe { nil }
	device          WGPUDevice
	format          WGPUTextureFormat
	usage           WGPUTextureUsage
	viewFormatCount usize
	viewFormats     &WGPUTextureFormat
	alphaMode       WGPUCompositeAlphaMode
	width           u32
	height          u32
	presentMode     WGPUPresentMode
}

pub struct C.WGPUSurfaceCapabilities {
	pub:
	nextInChain      &C.WGPUChainedStructOut = unsafe { nil }
	formatCount      usize
	formats          &WGPUTextureFormat
	presentModeCount usize
	presentModes     &WGPUPresentMode
	alphaModeCount   usize
	alphaModes       &WGPUCompositeAlphaMode
}

pub struct C.WGPUSurfaceTexture {
	pub:
	texture    WGPUTexture
	suboptimal WGPUBool
	status     WGPUSurfaceGetCurrentTextureStatus
}

pub struct C.WGPURenderPassDepthStencilAttachment {
	pub:
	view              WGPUTextureView
	depthLoadOp       WGPULoadOp
	depthStoreOp      WGPUStoreOp
	depthClearValue   f32
	depthReadOnly     WGPUBool
	stencilLoadOp     WGPULoadOp
	stencilStoreOp    WGPUStoreOp
	stencilClearValue u32
	stencilReadOnly   WGPUBool
}

pub struct C.WGPUTextureViewDescriptor {
	pub:
	nextInChain     &C.WGPUChainedStruct = unsafe { nil }
	label           &char
	format          WGPUTextureFormat
	dimension       WGPUTextureViewDimension
	baseMipLevel    u32
	mipLevelCount   u32
	baseArrayLayer  u32
	arrayLayerCount u32
	aspect          WGPUTextureAspect
}

pub struct C.WGPURenderPipelineDescriptor {
	pub:
	nextInChain  &C.WGPUChainedStruct = unsafe { nil }
	label        &char
	layout       WGPUPipelineLayout
	vertex       C.WGPUVertexState
	primitive    C.WGPUPrimitiveState
	depthStencil &C.WGPUDepthStencilState
	multisample  C.WGPUMultisampleState
	fragment     C.WGPUFragmentState
}

pub struct C.WGPUDepthStencilState {
	pub:
	nextInChain         &C.WGPUChainedStruct = unsafe { nil }
	format              WGPUTextureFormat
	depthWriteEnabled   WGPUBool
	depthCompare        WGPUCompareFunction
	stencilFront        C.WGPUStencilFaceState
	stencilBack         C.WGPUStencilFaceState
	stencilReadMask     u32
	stencilWriteMask    u32
	depthBias           int
	depthBiasSlopeScale f32
	depthBiasClamp      f32
}

pub struct C.WGPUStencilFaceState {
	pub:
	compare     WGPUCompareFunction
	failOp      WGPUStencilOperation
	depthFailOp WGPUStencilOperation
	passOp      WGPUStencilOperation
}

pub struct C.WGPUMultisampleState {
	pub:
	nextInChain            &C.WGPUChainedStruct = unsafe { nil }
	count                  u32
	mask                   u32
	alphaToCoverageEnabled WGPUBool
}

pub struct C.WGPUVertexState {
	pub:
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	shaderModule  WGPUShaderModule
	entryPoint    &char
	constantCount usize
	constants     &C.WGPUConstantEntry
	bufferCount   usize
	buffers       &C.WGPUVertexBufferLayout
}

pub struct C.WGPUFragmentState {
	pub:
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	module_       WGPUShaderModule
	entryPoint    &char
	constantCount usize
	constants     &C.WGPUConstantEntry
	targetCount   usize
	targets       &C.WGPUColorTargetState
}

pub struct C.WGPUColorTargetState {
	pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	format      WGPUTextureFormat
	blend       &C.WGPUBlendState
	writeMask   u32
}

pub struct C.WGPUBlendState {
	pub:
	color C.WGPUBlendComponent
	alpha C.WGPUBlendComponent
}

pub struct C.WGPUBlendComponent {
	pub:
	operation WGPUBlendOperation
	srcFactor WGPUBlendFactor
	dstFactor WGPUBlendFactor
}

pub struct C.WGPUPrimitiveState {
	pub:
	nextInChain      &C.WGPUChainedStruct = unsafe { nil }
	topology         WGPUPrimitiveTopology
	stripIndexFormat WGPUIndexFormat
	frontFace        WGPUFrontFace
	cullMode         WGPUCullMode
}

pub struct C.WGPUConstantEntry {
	pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	key         &char
	value       f64
}

pub struct C.WGPUVertexBufferLayout {
	pub:
	arrayStride    u64
	stepMode       WGPUVertexStepMode
	attributeCount usize
	attributes     &C.WGPUVertexAttribute
}

pub struct C.WGPUVertexAttribute {
	pub:
	format         WGPUVertexFormat
	offset         u64
	shaderLocation u32
}

pub struct C.WGPUShaderModuleDescriptor {
	pub:
	nextInChain &C.WGPUChainedStruct
	label       &char
	hintCount   usize
	hints       &C.WGPUShaderModuleCompilationHint
}

pub struct C.WGPUShaderModuleWGSLDescriptor {
	pub:
	chain C.WGPUChainedStruct
	code  &char
}

pub struct C.WGPUShaderModuleCompilationHint {
	pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	entryPoint  &char
	layout      WGPUPipelineLayout
}

pub struct C.WGPUPipelineLayoutDescriptor {
	pub:
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	label                &char
	bindGroupLayoutCount usize
	bindGroupLayouts     &WGPUBindGroupLayout
}