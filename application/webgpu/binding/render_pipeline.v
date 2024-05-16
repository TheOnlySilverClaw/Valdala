module binding

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

pub fn C.wgpuRenderPipelineRelease(pipeline WGPURenderPipeline)
