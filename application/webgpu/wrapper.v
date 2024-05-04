module webgpu

#flag -I include
#flag -L libraries

#flag -l c
#flag -l m
#flag -l unwind
#flag -l wgpu_native

#include "wgpu.h"


pub fn create_instance() !WGPUInstance {

	descriptor := C.WGPUInstanceDescriptor{}
	instance := C.wgpuCreateInstance(&descriptor)
	return instance
}

pub fn (instance WGPUInstance) release() {
	C.wgpuInstanceRelease(instance)
}

pub fn (instance WGPUInstance) request_adapter(surface WGPUSurface) !WGPUAdapter {


	options := C.WGPURequestAdapterOptions{
		powerPreference: .high_performance,
		compatibleSurface: surface
	}

	channel := chan WGPUAdapter{cap: 1}

	callback := fn [channel] (
		status WGPURequestAdapterStatus,
		adapter WGPUAdapter,
		message &char,
		user_data voidptr) {
		
		if status == .success {
			channel <- adapter
		} else {
			channel.close()
		}
	}

	user_data := unsafe { nil }

	C.wgpuInstanceRequestAdapter(instance, &options, callback, user_data)

	adapter := <- channel ?

	return adapter
}

pub fn (adapter WGPUAdapter) release() {
	C.wgpuAdapterRelease(adapter)
}


pub fn (surface WGPUSurface) release() {
	C.wgpuSurfaceRelease(surface)
}