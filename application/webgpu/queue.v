module webgpu

import webgpu.binding

pub type WorkDoneStatus = binding.WGPUQueueWorkDoneStatus

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

pub type WorkDoneListener = fn(status WorkDoneStatus)

pub fn (queue Queue) on_work_done(listener WorkDoneListener) {

	callback := fn[listener](status binding.WGPUQueueWorkDoneStatus, userdata voidptr) {
		listener(status)
	}

	C.wgpuQueueOnSubmittedWorkDone(queue.ptr, callback, unsafe { nil })
}

pub fn (queue Queue) release() {
	C.wgpuQueueRelease(queue.ptr)
}
