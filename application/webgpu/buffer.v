module webgpu

import webgpu.binding

pub type BufferUsage = binding.WGPUBufferUsage

pub struct Buffer {
pub:
	ptr  binding.WGPUBuffer
	size u64
}

pub fn (buffer Buffer) unmap() {
	C.wgpuBufferUnmap(buffer.ptr)
}

pub fn (buffer Buffer) destroy() {
	C.wgpuBufferDestroy(buffer.ptr)
}
