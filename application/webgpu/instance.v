module webgpu

pub type Instance = voidptr

pub fn create_instance() !Instance {

	descriptor := C.WGPUInstanceDescriptor{}
	instance := C.wgpuCreateInstance(&descriptor)
	return instance
}

pub fn (instance Instance) release() {
	C.wgpuInstanceRelease(instance)
}