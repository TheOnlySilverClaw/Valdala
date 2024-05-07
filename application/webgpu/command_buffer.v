module webgpu

import webgpu.binding

pub struct CommandBuffer {
	ptr binding.WGPUCommandBuffer
}

pub fn (buffer CommandBuffer) release() {
	C.wgpuCommandBufferRelease(buffer.ptr)
}