module binding

pub struct C.WGPUPipelineLayoutDescriptor {
pub:
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	label                &char
	bindGroupLayoutCount usize
	bindGroupLayouts     &WGPUBindGroupLayout
}

pub fn C.wgpuPipelineLayoutRelease(layout WGPUPipelineLayout)
