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

enum WGPUSType {
	invalid                                       = 0x00000000
	surface_descriptor_from_metal_layer           = 0x00000001
	surface_descriptor_from_windows_hwnd          = 0x00000002
	surface_descriptor_from_xlib_window           = 0x00000003
	surface_descriptor_from_canvas_html_selector  = 0x00000004
	shader_module_spirv_descriptor                = 0x00000005
	shader_module_wgsl_descriptor                 = 0x00000006
	primitive_depth_clip_control                  = 0x00000007
	surface_descriptor_from_wayland_surface       = 0x00000008
	surface_descriptor_from_android_native_window = 0x00000009
	surface_descriptor_from_xcb_window            = 0x0000000A
	render_pass_descriptor_max_draw_count         = 0x0000000F
	// force32         = 0x7FFFFFFF
}

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
	undefined                 = 0
	depth_clip_control        = 1
	depth32_floatstencil8     = 2
	timestamp_query           = 3
	texture_compression_bc    = 4
	texture_compression_etc2  = 5
	texture_compression_astc  = 6
	indirect_first_instance   = 7
	shaderf16                 = 8
	rg11b10_ufloat_renderable = 9
	bgra8_unorm_storage       = 10
	float32_filterable        = 11
	// force32   = 0x7FFFFFFF
}

enum WGPUDeviceLostReason {
	undefined = 0
	destroyed = 1
	// force32   = 0x7FFFFFFF
}

enum WGPUErrorType {
	no_error      = 0
	validation    = 1
	out_of_memory = 2
	internal      = 3
	unknown       = 4
	device_lost   = 5
	// force32   = 0x7FFFFFFF
}

enum WGPULoadOp {
	undefined = 0
	clear     = 1
	load      = 2
	// force32   = 0x7FFFFFFF
}

enum WGPUStoreOp {
	undefined = 0
	store     = 1
	discard   = 2
	// force32   = 0x7FFFFFFF
}

enum WGPUSurfaceGetCurrentTextureStatus {
	success       = 0
	timeout       = 1
	outdated      = 2
	lost          = 3
	out_of_memory = 4
	device_lost   = 5
	// force32   = 0x7FFFFFFF
}

enum WGPUTextureFormat {
	undefined            = 0
	r8unorm              = 1
	r8snorm              = 2
	r8uint               = 3
	r8sint               = 4
	r16uint              = 5
	r16sint              = 6
	r16float             = 7
	rg8unorm             = 8
	rg8snorm             = 9
	rg8uint              = 10
	rg8sint              = 11
	r32float             = 12
	r32uint              = 13
	r32sint              = 14
	rg16uint             = 15
	rg16sint             = 16
	rg16float            = 17
	rgba8unorm           = 18
	rgba8unormsrgb       = 19
	rgba8snorm           = 20
	rgba8uint            = 21
	rgba8sint            = 22
	bgra8unorm           = 23
	bgra8unormsrgb       = 24
	rgb10a2uint          = 25
	rgb10a2unorm         = 26
	rg11b10ufloat        = 27
	rgb9e5ufloat         = 28
	rg32float            = 29
	rg32uint             = 30
	rg32sint             = 31
	rgba16uint           = 32
	rgba16sint           = 33
	rgba16float          = 34
	rgba32float          = 35
	rgba32uint           = 36
	rgba32sint           = 37
	stencil8             = 38
	depth16unorm         = 39
	depth24plus          = 40
	depth24plusstencil8  = 41
	depth32float         = 42
	depth32floatstencil8 = 43
	bc1rgbaunorm         = 44
	bc1rgbaunormsrgb     = 45
	bc2rgbaunorm         = 46
	bc2rgbaunormsrgb     = 47
	bc3rgbaunorm         = 48
	bc3rgbaunormsrgb     = 49
	bc4runorm            = 50
	bc4rsnorm            = 51
	bc5rgunorm           = 52
	bc5rgsnorm           = 53
	bc6hrgbufloat        = 54
	bc6hrgbfloat         = 55
	bc7rgbaunorm         = 56
	bc7rgbaunormsrgb     = 57
	etc2rgb8unorm        = 58
	etc2rgb8unormsrgb    = 59
	etc2rgb8a1unorm      = 60
	etc2rgb8a1unormsrgb  = 61
	etc2rgba8unorm       = 62
	etc2rgba8unormsrgb   = 63
	eacr11unorm          = 64
	eacr11snorm          = 65
	eacrg11unorm         = 66
	eacrg11snorm         = 67
	astc4x4unorm         = 68
	astc4x4unormsrgb     = 69
	astc5x4unorm         = 70
	astc5x4unormsrgb     = 71
	astc5x5unorm         = 72
	astc5x5unormsrgb     = 73
	astc6x5unorm         = 74
	astc6x5unormsrgb     = 75
	astc6x6unorm         = 76
	astc6x6unormsrgb     = 77
	astc8x5unorm         = 78
	astc8x5unormsrgb     = 79
	astc8x6unorm         = 80
	astc8x6unormsrgb     = 81
	astc8x8unorm         = 82
	astc8x8unormsrgb     = 83
	astc10x5unorm        = 84
	astc10x5unormsrgb    = 85
	astc10x6unorm        = 86
	astc10x6unormsrgb    = 87
	astc10x8unorm        = 88
	astc10x8unormsrgb    = 89
	astc10x10unorm       = 90
	astc10x10unormsrgb   = 91
	astc12x10unorm       = 92
	astc12x10unormsrgb   = 93
	astc12x12unorm       = 94
	astc12x12unormsrgb   = 95
	// force32   = 0x7FFFFFFF
}

enum WGPUTextureUsage {
	unused            = 0 // should be "none", but that is a reserved keyword
	copy_src          = 1
	copy_dst          = 2
	texture_binding   = 4
	storage_binding   = 8
	render_attachment = 16
	// force32   = 0x7FFFFFFF
}

enum WGPUTextureViewDimension {
	undefined  = 0
	single_1d  = 1
	single_2d  = 2
	array_2d   = 3
	cube       = 4
	array_cube = 5
	single_3d  = 6
	// force32   = 0x7FFFFFFF
}

enum WGPUTextureAspect {
	all          = 0
	stencil_only = 1
	depth_only   = 2
	// force32   = 0x7FFFFFFF
}

enum WGPUCompositeAlphaMode {
	auto            = 0
	opaque          = 1
	premultiplied   = 2
	unpremultiplied = 3
	inherit         = 4
	// force32   = 0x7FFFFFFF
}

enum WGPUPresentMode {
	fifo         = 0
	fifo_relaxed = 1
	immediate    = 2
	mailbox      = 3
	// force32   = 0x7FFFFFFF
}

enum WGPUVertexFormat {
	undefined = 0
	uint8x2   = 1
	uint8x4   = 2
	sint8x2   = 3
	sint8x4   = 4
	unorm8x2  = 5
	unorm8x4  = 6
	snorm8x2  = 7
	snorm8x4  = 8
	uint16x2  = 9
	uint16x4  = 10
	sint16x2  = 11
	sint16x4  = 12
	unorm16x2 = 13
	unorm16x4 = 14
	snorm16x2 = 15
	snorm16x4 = 16
	float16x2 = 17
	float16x4 = 18
	float32   = 19
	float32x2 = 20
	float32x3 = 21
	float32x4 = 22
	uint32    = 23
	uint32x2  = 24
	uint32x3  = 25
	uint32x4  = 26
	sint32    = 27
	sint32x2  = 28
	sint32x3  = 29
	sint32x4  = 30
	// force32   = 0x7FFFFFFF
}

enum WGPUIndexFormat {
	undefined = 0
	uint16    = 1
	uint32    = 2
	// force32   = 0x7FFFFFFF
}

enum WGPUPrimitiveTopology {
	point_list     = 0
	line_list      = 1
	line_strip     = 2
	triangle_list  = 3
	triangle_strip = 4
	// force32   = 0x7FFFFFFF
}

enum WGPUVertexStepMode {
	vertex                 = 0
	instance               = 1
	vertex_buffer_not_used = 2
	// force32   = 0x7FFFFFFF
}

enum WGPUCullMode {
	neither = 0 // "none" is reserved
	front   = 1
	back    = 2
	// force32   = 0x7FFFFFFF
}

enum WGPUFrontFace {
	ccw = 0
	cw  = 1
	// force32   = 0x7FFFFFFF
}

enum WGPUBlendOperation {
	add              = 0
	subtract         = 1
	reverse_subtract = 2
	min              = 3
	max              = 4
	// force32   = 0x7FFFFFFF
}

enum WGPUBlendFactor {
	zero                = 0
	one                 = 1
	src                 = 2
	one_minus_src       = 3
	src_alpha           = 4
	one_minus_src_alpha = 5
	dst                 = 6
	one_minus_dst       = 7
	dst_alpha           = 8
	one_minus_dst_alpha = 9
	src_alpha_saturated = 10
	constant            = 11
	one_minus_constant  = 12
	// force32   = 0x7FFFFFFF
}

enum WGPUCompareFunction {
	undefined     = 0
	never         = 1
	less          = 2
	less_equal    = 3
	greater       = 4
	greater_equal = 5
	equal         = 6
	not_equal     = 7
	always        = 8
	// force32   = 0x7FFFFFFF
}

enum WGPUStencilOperation {
	keep            = 0
	zero            = 1
	replace         = 2
	invert          = 3
	increment_clamp = 4
	decrement_clamp = 5
	increment_wrap  = 6
	decrement_wrap  = 7
	// force32   = 0x7FFFFFFF
}

struct C.WGPUChainedStruct {
	next &C.WGPUChainedStruct
	sType WGPUSType
}

struct C.WGPUChainedStructOut {
	next  &C.WGPUChainedStructOut
	sType WGPUSType
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

struct C.WGPUColor {
	r f64
	g f64
	b f64
	a f64
}

struct C.WGPUCommandBufferDescriptor {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

struct C.WGPUCommandEncoderDescriptor {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

struct C.WGPURenderPassColorAttachment {
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	view          WGPUTextureView
	resolveTarget WGPUTextureView
	loadOp        WGPULoadOp
	storeOp       WGPUStoreOp
	clearValue    C.WGPUColor
}

struct C.WGPURenderPassTimestampWrites {
	querySet                  WGPUQuerySet
	beginningOfPassWriteIndex u32
	endOfPassWriteIndex       u32
}

struct C.WGPURenderPassDescriptor {
	nextInChain            &C.WGPUChainedStruct = unsafe { nil }
	label                  &char
	colorAttachmentCount   usize
	colorAttachments       &C.WGPURenderPassColorAttachment
	depthStencilAttachment &C.WGPURenderPassDepthStencilAttachment
	occlusionQuerySet      WGPUQuerySet
	timestampWrites        &C.WGPURenderPassTimestampWrites
}

struct C.WGPUSurfaceConfiguration {
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

struct C.WGPUSurfaceCapabilities {
	nextInChain      &C.WGPUChainedStructOut = unsafe { nil }
	formatCount      usize
	formats          &WGPUTextureFormat
	presentModeCount usize
	presentModes     &WGPUPresentMode
	alphaModeCount   usize
	alphaModes       &WGPUCompositeAlphaMode
}

struct C.WGPUSurfaceTexture {
	texture    WGPUTexture
	suboptimal WGPUBool
	status     WGPUSurfaceGetCurrentTextureStatus
}

struct C.WGPURenderPassDepthStencilAttachment {
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

struct C.WGPUTextureViewDescriptor {
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

struct C.WGPURenderPipelineDescriptor {
	nextInChain  &C.WGPUChainedStruct = unsafe { nil }
	label        &char
	layout       WGPUPipelineLayout
	vertex       C.WGPUVertexState
	primitive    C.WGPUPrimitiveState
	depthStencil &C.WGPUDepthStencilState
	multisample  C.WGPUMultisampleState
	fragment     C.WGPUFragmentState
}

struct C.WGPUDepthStencilState {
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

struct C.WGPUStencilFaceState {
	compare     WGPUCompareFunction
	failOp      WGPUStencilOperation
	depthFailOp WGPUStencilOperation
	passOp      WGPUStencilOperation
}

struct C.WGPUMultisampleState {
	nextInChain            &C.WGPUChainedStruct = unsafe { nil }
	count                  u32
	mask                   u32
	alphaToCoverageEnabled WGPUBool
}

struct C.WGPUVertexState {
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	shaderModule  WGPUShaderModule
	entryPoint    &char
	constantCount usize
	constants     &C.WGPUConstantEntry
	bufferCount   usize
	buffers       &C.WGPUVertexBufferLayout
}

struct C.WGPUFragmentState {
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	module_       WGPUShaderModule
	entryPoint    &char
	constantCount usize
	constants     &C.WGPUConstantEntry
	targetCount   usize
	targets       &C.WGPUColorTargetState
}

struct C.WGPUColorTargetState {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	format      WGPUTextureFormat
	blend       &C.WGPUBlendState
	writeMask   u32
}

struct C.WGPUBlendState {
	color C.WGPUBlendComponent
	alpha C.WGPUBlendComponent
}

struct C.WGPUBlendComponent {
	operation WGPUBlendOperation
	srcFactor WGPUBlendFactor
	dstFactor WGPUBlendFactor
}

struct C.WGPUPrimitiveState {
	nextInChain      &C.WGPUChainedStruct = unsafe { nil }
	topology         WGPUPrimitiveTopology
	stripIndexFormat WGPUIndexFormat
	frontFace        WGPUFrontFace
	cullMode         WGPUCullMode
}

struct C.WGPUConstantEntry {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	key         &char
	value       f64
}

struct C.WGPUVertexBufferLayout {
	arrayStride    u64
	stepMode       WGPUVertexStepMode
	attributeCount usize
	attributes     &C.WGPUVertexAttribute
}

struct C.WGPUVertexAttribute {
	format         WGPUVertexFormat
	offset         u64
	shaderLocation u32
}

struct C.WGPUShaderModuleDescriptor {
	nextInChain &C.WGPUChainedStruct
	label       &char
	hintCount   usize
	hints       &C.WGPUShaderModuleCompilationHint
}

struct C.WGPUShaderModuleWGSLDescriptor {
	chain C.WGPUChainedStruct
	code  &char
}

struct C.WGPUShaderModuleCompilationHint {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	entryPoint  &char
	layout      WGPUPipelineLayout
}

type WGPURequestAdapterCallback = fn (status WGPURequestAdapterStatus, adapter WGPUAdapter, message &char, user_data voidptr)

type WGPURequestDeviceCallback = fn (status WGPURequestDeviceStatus, device WGPUDevice, message &char, user_data voidptr)

type WGPUDeviceLostCallback = fn (reason WGPUDeviceLostReason, message &char, user_data voidptr)

type WGPUErrorCallback = fn (errorType WGPUErrorType, message &char, user_data voidptr)
