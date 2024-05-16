module binding

pub struct C.WGPUQueueDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

pub fn C.wgpuQueueWriteBuffer(queue WGPUQueue, buffer WGPUBuffer, bufferOffset u64, data voidptr, size usize)

pub fn C.wgpuQueueSubmit(queue WGPUQueue, command_count usize, commands &WGPUCommandBuffer)

pub fn C.wgpuQueueRelease(queue WGPUQueue)
