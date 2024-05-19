module binding

pub fn C.wgpuRenderPipelineRelease(pipeline WGPURenderPipeline)

pub struct C.WGPURenderPipelineDescriptor {
pub:
	nextInChain  &C.WGPUChainedStruct = unsafe { nil }
	label        &char
	layout       WGPUPipelineLayout
	vertex       C.WGPUVertexState
	primitive    C.WGPUPrimitiveState
	depthStencil &C.WGPUDepthStencilState
	multisample  C.WGPUMultisampleState
	fragment     &C.WGPUFragmentState
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
	@module       WGPUShaderModule
	entryPoint    &char
	constantCount usize
	constants     &C.WGPUConstantEntry
	bufferCount   usize
	buffers       &C.WGPUVertexBufferLayout
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

pub struct C.WGPUPrimitiveState {
pub:
	nextInChain      &C.WGPUChainedStruct = unsafe { nil }
	topology         WGPUPrimitiveTopology
	stripIndexFormat WGPUIndexFormat
	frontFace        WGPUFrontFace
	cullMode         WGPUCullMode
}

pub struct C.WGPUFragmentState {
pub:
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	@module       WGPUShaderModule
	entryPoint    &char
	constantCount usize
	constants     &C.WGPUConstantEntry
	targetCount   usize
	targets       &C.WGPUColorTargetState
}

pub struct C.WGPUConstantEntry {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	key         &char
	value       f64
}

pub struct C.WGPUColorTargetState {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	format      WGPUTextureFormat
	blend       &C.WGPUBlendState
	writeMask   WGPUColorWriteMask
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

pub enum WGPUVertexFormat {
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
}

pub enum WGPUIndexFormat {
	undefined = 0
	uint16    = 1
	uint32    = 2
}

pub enum WGPUPrimitiveTopology {
	point_list     = 0
	line_list      = 1
	line_strip     = 2
	triangle_list  = 3
	triangle_strip = 4
}

pub enum WGPUVertexStepMode {
	vertex                 = 0
	instance               = 1
	vertex_buffer_not_used = 2
}

pub enum WGPUCullMode {
	@none = 0
	front = 1
	back  = 2
}

pub enum WGPUFrontFace {
	ccw = 0
	cw  = 1
}

pub enum WGPUBlendOperation {
	add              = 0
	subtract         = 1
	reverse_subtract = 2
	min              = 3
	max              = 4
}

pub enum WGPUBlendFactor {
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
}

pub enum WGPUCompareFunction {
	undefined     = 0
	never         = 1
	less          = 2
	less_equal    = 3
	greater       = 4
	greater_equal = 5
	equal         = 6
	not_equal     = 7
	always        = 8
}

pub enum WGPUStencilOperation {
	keep            = 0
	zero            = 1
	replace         = 2
	invert          = 3
	increment_clamp = 4
	decrement_clamp = 5
	increment_wrap  = 6
	decrement_wrap  = 7
}

@[flag]
pub enum WGPUColorWriteMask {
	red
	green
	blue
	alpha
}
