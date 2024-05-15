module webgpu

import webgpu.binding

pub struct Queue {
	ptr binding.WGPUQueue
}

pub fn (queue Queue) submit(command ...CommandBuffer) {
	pointers := command.map(it.ptr)
	C.wgpuQueueSubmit(queue.ptr, pointers.len, &pointers[0])
}

pub fn (queue Queue) release() {
	C.wgpuQueueRelease(queue.ptr)
}
