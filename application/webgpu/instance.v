module webgpu

import webgpu.binding

pub struct Instance {
	// TODO figure out exposure to glfw
	pub:
	ptr binding.WGPUInstance
}

pub fn create_instance() !Instance {

	descriptor := C.WGPUInstanceDescriptor{}
	instance := C.wgpuCreateInstance(&descriptor)

	return Instance{
		ptr: instance
	}
}

pub fn (instance Instance) request_adapter(surface Surface) !Adapter {

	options := C.WGPURequestAdapterOptions {
		powerPreference: .high_performance,
		compatibleSurface: surface.ptr
	}

	channel := chan binding.WGPUAdapter{cap: 1}

	callback := fn [channel] (
		status binding.WGPURequestAdapterStatus,
		adapter binding.WGPUAdapter,
		message &char,
		user_data voidptr) {
		
		if status == .success {
			channel <- adapter
		} else {
			channel.close()
		}
	}

	C.wgpuInstanceRequestAdapter(instance.ptr, &options, callback, unsafe { nil })

	adapter := <- channel ?

	return Adapter { ptr: adapter }
}

pub fn (instance Instance) release() {
	C.wgpuInstanceRelease(instance.ptr)
}
