module webgpu

import webgpu.binding

pub struct Queue {
	ptr binding.WGPUQueue
}

pub fn (queue Queue) write_buffer[T](buffer Buffer, offset u64, entries []T) {
	C.wgpuQueueWriteBuffer(queue.ptr, buffer.ptr, offset, entries.data, entries.len * sizeof(T))
}

pub fn (queue Queue) submit(command ...CommandBuffer) {
	pointers := command.map(it.ptr)
	C.wgpuQueueSubmit(queue.ptr, pointers.len, pointers.data)
}

pub fn (queue Queue) release() {
	C.wgpuQueueRelease(queue.ptr)
}
