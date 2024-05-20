module webgpu

import webgpu.binding

pub struct CommandBuffer {
	ptr binding.WGPUCommandBuffer
}

pub fn (encoder CommandEncoder) finish() CommandBuffer {
	descriptor := &C.WGPUCommandBufferDescriptor{
		label: unsafe { nil }
	}

	buffer := C.wgpuCommandEncoderFinish(encoder.ptr, descriptor)
	return CommandBuffer{
		ptr: buffer
	}
}

pub fn (buffer CommandBuffer) release() {
	C.wgpuCommandBufferRelease(buffer.ptr)
}
