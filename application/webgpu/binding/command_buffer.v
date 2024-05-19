module binding

pub fn C.wgpuCommandBufferRelease(buffer WGPUCommandBuffer)

pub type WGPUCommandBuffer = voidptr

pub struct C.WGPUCommandBufferDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}
