module webgpu

import webgpu.binding

type ColorWriteMask = binding.WGPUColorWriteMask

pub struct Device {
	ptr binding.WGPUDevice
}

pub fn (adapter Adapter) request_device() !Device {
	descriptor := C.WGPUDeviceDescriptor{
		label: 'device'.str
		requiredFeatures: unsafe { nil }
		requiredLimits: unsafe { nil }
	}

	channel := chan binding.WGPUDevice{cap: 1}

	callback := fn [channel] (status binding.WGPURequestDeviceStatus, device binding.WGPUDevice, message &char, user_data voidptr) {
		if status == .success {
			channel <- device
		} else {
			channel.close()
		}
	}

	C.wgpuAdapterRequestDevice(adapter.ptr, &descriptor, callback, unsafe { nil })

	device := <-channel?

	error_callback := fn (errorType binding.WGPUErrorType, message &char, user_data voidptr) {
		message_string := unsafe { message.vstring() }
		println('device error (${errorType}): ${message_string}')
	}

	C.wgpuDeviceSetUncapturedErrorCallback(device, error_callback, unsafe { nil })

	return Device{
		ptr: device
	}
}

pub fn (device Device) release() {
	C.wgpuDeviceRelease(device.ptr)
}
