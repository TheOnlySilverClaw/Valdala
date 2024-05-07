module webgpu

import webgpu.binding

pub struct ShaderModule {
	ptr binding.WGPUShaderModule
}

pub fn(shader ShaderModule) release() {
	C.wgpuShaderModuleRelease(shader.ptr)
}