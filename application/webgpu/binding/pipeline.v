module binding

pub fn C.wgpuPipelineLayoutRelease(layout WGPUPipelineLayout)

pub struct C.WGPUPipelineLayoutDescriptor {
pub:
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	label                &char
	bindGroupLayoutCount usize
	bindGroupLayouts     &WGPUBindGroupLayout
}
