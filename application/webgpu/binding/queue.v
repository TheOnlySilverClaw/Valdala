module binding

pub struct C.WGPUQueueDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

pub fn C.wgpuQueueSubmit(queue WGPUQueue, command_count usize, commands &WGPUCommandBuffer)

pub fn C.wgpuQueueRelease(queue WGPUQueue)
