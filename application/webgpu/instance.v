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

pub fn (instance Instance) release() {
	C.wgpuInstanceRelease(instance.ptr)
}
