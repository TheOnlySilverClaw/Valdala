module webgpu

#flag -I include
#flag -L libraries

#flag -l c
#flag -l m
#flag -l unwind
#flag -l wgpu_native

#include "wgpu.h"

pub type Instance = voidptr
pub type Adapter = voidptr

pub fn create_instance() !Instance {
	descriptor := C.WGPUInstanceDescriptor{}
	instance := C.wgpuCreateInstance(&descriptor)
	return instance
}

pub fn (instance Instance) release() {
	C.wgpuInstanceRelease(instance)
}

pub fn (instance Instance) request_adapter() !Adapter {


	options := C.WGPURequestAdapterOptions{
		powerPreference: .high_performance
	}

	channel := chan Adapter{cap: 1}

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

pub fn (adapter Adapter) release() {
	C.wgpuAdapterRelease(adapter)
}
