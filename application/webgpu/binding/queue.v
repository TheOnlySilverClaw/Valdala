module binding

pub type WGPUQueueOnSubmittedWorkDoneCallback = fn (status WGPUQueueWorkDoneStatus, userdata voidptr)

pub struct C.WGPUQueueDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

pub fn C.wgpuQueueWriteBuffer(queue WGPUQueue, buffer WGPUBuffer, bufferOffset u64, data voidptr, size usize)

pub fn C.wgpuQueueWriteTexture(queue WGPUQueue, destination &C.WGPUImageCopyTexture, data voidptr, dataSize usize, dataLayout &C.WGPUTextureDataLayout, writeSize &C.WGPUExtent3D)

pub fn C.wgpuQueueSubmit(queue WGPUQueue, command_count usize, commands &WGPUCommandBuffer)

pub fn C.wgpuQueueOnSubmittedWorkDone(queue WGPUQueue, callback WGPUQueueOnSubmittedWorkDoneCallback, userdata voidptr)

pub fn C.wgpuQueueRelease(queue WGPUQueue)
