module webgpu

import binding

pub struct Adapter {
	ptr binding.WGPUAdapter
}

pub fn (instance Instance) request_adapter(surface Surface) !Adapter {
	options := C.WGPURequestAdapterOptions{
		powerPreference: .high_performance
		compatibleSurface: surface.ptr
	}

	channel := chan binding.WGPUAdapter{cap: 1}

	callback := fn [channel] (status binding.WGPURequestAdapterStatus, adapter binding.WGPUAdapter, message &char, user_data voidptr) {
		if status == .success {
			channel <- adapter
		} else {
			channel.close()
		}
	}

	C.wgpuInstanceRequestAdapter(instance.ptr, &options, callback, unsafe { nil })

	adapter := <-channel?

	return Adapter{
		ptr: adapter
	}
}

pub fn (adapter Adapter) release() {
	C.wgpuAdapterRelease(adapter.ptr)
}
