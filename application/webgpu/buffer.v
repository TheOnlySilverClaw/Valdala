module webgpu

import webgpu.binding

pub type BufferUsage = binding.WGPUBufferUsage

pub struct Buffer {
pub:
	ptr  binding.WGPUBuffer
	size u64
}

pub fn (device Device) create_buffer(label string, size u32) Buffer {
	descriptor := &C.WGPUBufferDescriptor{
		label: label.str
		usage: .vertex | .copy_dst
		mappedAtCreation: 0
		size: size
	}

	buffer := C.wgpuDeviceCreateBuffer(device.ptr, descriptor)
	return Buffer{
		ptr: buffer
		size: size
	}
}

pub fn (buffer Buffer) unmap() {
	C.wgpuBufferUnmap(buffer.ptr)
}

pub fn (buffer Buffer) destroy() {
	C.wgpuBufferDestroy(buffer.ptr)
}
