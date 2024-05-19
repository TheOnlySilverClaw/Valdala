module binding

pub fn C.wgpuCommandEncoderBeginRenderPass(commandEncoder WGPUCommandEncoder, descriptor &C.WGPURenderPassDescriptor) WGPURenderPassEncoder

pub fn C.wgpuCommandEncoderFinish(encoder WGPUCommandEncoder, descriptor &C.WGPUCommandBufferDescriptor) WGPUCommandBuffer

pub fn C.wgpuCommandEncoderRelease(encoder WGPUCommandEncoder)

pub type WGPUCommandEncoder = voidptr

pub struct C.WGPUCommandEncoderDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}
