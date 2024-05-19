module binding

pub fn C.wgpuPipelineLayoutRelease(layout WGPUPipelineLayout)

pub type WGPUPipelineLayout = voidptr

pub struct C.WGPUPipelineLayoutDescriptor {
pub:
	nextInChain          &C.WGPUChainedStruct = unsafe { nil }
	label                &char
	bindGroupLayoutCount usize
	bindGroupLayouts     &WGPUBindGroupLayout
}
