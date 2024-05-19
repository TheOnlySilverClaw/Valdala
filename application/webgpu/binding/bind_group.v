module binding

pub fn C.wgpuBindGroupRelease(bindGroup WGPUBindGroup)

pub struct C.WGPUBindGroupDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
	layout      WGPUBindGroupLayout
	entryCount  usize
	entries     &C.WGPUBindGroupEntry
}

pub struct C.WGPUBindGroupEntry {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	binding     u32
	buffer      WGPUBuffer
	offset      u64
	size        u64
	sampler     WGPUSampler
	textureView WGPUTextureView
}
