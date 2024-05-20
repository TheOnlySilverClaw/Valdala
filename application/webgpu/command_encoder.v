module webgpu

import webgpu.binding

pub struct CommandEncoder {
	ptr binding.WGPUCommandEncoder
}

pub fn (device Device) create_command_encoder(label string) CommandEncoder {
	descriptor := C.WGPUCommandEncoderDescriptor{
		label: label.str
	}
	encoder := C.wgpuDeviceCreateCommandEncoder(device.ptr, &descriptor)
	return CommandEncoder{
		ptr: encoder
	}
}

pub fn (encoder CommandEncoder) release() {
	C.wgpuCommandEncoderRelease(encoder.ptr)
}
