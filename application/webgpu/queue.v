module webgpu

import webgpu.binding

pub type WorkDoneStatus = binding.WGPUQueueWorkDoneStatus

pub struct Queue {
	ptr binding.WGPUQueue
}

pub fn (queue Queue) write_buffer[T](buffer Buffer, offset u64, data []T) {
	size := (usize(data.len) - offset) * sizeof(T)
	C.wgpuQueueWriteBuffer(queue.ptr, buffer.ptr, offset, data.data, size)
}

@[params]
pub struct TextureWriteOptions {
pub:
	mip_level u32
	origin    Origin        = Origin{}
	aspect    TextureAspect = .all
	offset    u32
	width     u32
	height    u32
	layers    u32
	layout    TextureDataLayout
}

pub type Origin = C.WGPUOrigin3D
pub type TextureDataLayout = C.WGPUTextureDataLayout

pub fn (queue Queue) write_texture[T](texture Texture, data []T, options TextureWriteOptions) {
	destination := &C.WGPUImageCopyTexture{
		texture: texture.ptr
		mipLevel: options.mip_level
		origin: options.origin
		aspect: options.aspect
	}

	layout := &options.layout

	write_size := &C.WGPUExtent3D{
		width: options.width
		height: options.height
		depthOrArrayLayers: options.layers
	}

	size := data.len * sizeof(T)
	C.wgpuQueueWriteTexture(queue.ptr, destination, data.data, size, layout, write_size)
}

pub fn (queue Queue) submit(command ...CommandBuffer) {
	pointers := command.map(it.ptr)
	C.wgpuQueueSubmit(queue.ptr, pointers.len, pointers.data)
}

pub type WorkDoneListener = fn (status WorkDoneStatus)

pub fn (queue Queue) on_work_done(listener WorkDoneListener) {
	callback := fn [listener] (status binding.WGPUQueueWorkDoneStatus, userdata voidptr) {
		listener(status)
	}

	C.wgpuQueueOnSubmittedWorkDone(queue.ptr, callback, unsafe { nil })
}

pub fn (queue Queue) release() {
	C.wgpuQueueRelease(queue.ptr)
}
