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

	C.wgpuInstanceRequestAdapter(instance, &options, callback, unsafe { nil })

	adapter := <- channel ?

	return adapter
}

pub fn (adapter WGPUAdapter) release() {
	C.wgpuAdapterRelease(adapter)
}

pub fn (adapter WGPUAdapter) request_device() !WGPUDevice {

	descriptor := C.WGPUDeviceDescriptor{
		label: "device".str,
		requiredFeatures: unsafe { nil },
		requiredLimits: unsafe { nil }
	}

	channel := chan WGPUDevice{cap: 1}

	callback := fn [channel] (
		status WGPURequestDeviceStatus,
		device WGPUDevice,
		message &char,
		user_data voidptr) {
		
		if status == .success {
			channel <- device
		} else {
			channel.close()
		}
	}

	C.wgpuAdapterRequestDevice(adapter, &descriptor, callback, unsafe { nil })

	device := <- channel ?

	error_callback := fn(errorType WGPUErrorType, message &char, user_data voidptr) {
		message_string := unsafe { message.vstring() }
		println("device error ($errorType): $message_string")
	}

	C.wgpuDeviceSetUncapturedErrorCallback(device, error_callback, unsafe { nil })
	
	return device
}

pub fn (device WGPUDevice) release() {
	C.wgpuDeviceRelease(device)
}

pub fn (surface WGPUSurface) release() {
	C.wgpuSurfaceRelease(surface)
}