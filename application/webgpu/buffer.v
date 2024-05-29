module webgpu

import webgpu.binding

pub type BufferUsage = binding.WGPUBufferUsage

pub struct Buffer {
pub:
	ptr   binding.WGPUBuffer
	size  u64
	usage BufferUsage
pub mut:
	mapped bool
}

@[params]
pub struct BufferOptions {
pub:
	label  string
	size   u32                     @[required]
	usage  binding.WGPUBufferUsage @[required]
	mapped bool
}

pub fn (device Device) create_buffer(options BufferOptions) Buffer {
	descriptor := &C.WGPUBufferDescriptor{
		label: options.label.str
		size: options.size
		usage: options.usage
		mappedAtCreation: if options.mapped { 1 } else { 0 }
	}

	buffer := C.wgpuDeviceCreateBuffer(device.ptr, descriptor)
	return Buffer{
		ptr: buffer
		size: options.size
		usage: options.usage
		mapped: options.mapped
	}
}

pub fn (mut buffer Buffer) unmap() {
	C.wgpuBufferUnmap(buffer.ptr)
	buffer.mapped = false
}

pub fn (buffer Buffer) destroy() {
	C.wgpuBufferDestroy(buffer.ptr)
}
