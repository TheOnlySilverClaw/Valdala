module binding

pub struct C.WGPUCommandBufferDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

pub fn C.wgpuCommandBufferRelease(buffer WGPUCommandBuffer)
