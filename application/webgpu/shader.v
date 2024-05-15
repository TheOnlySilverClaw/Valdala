module webgpu

import webgpu.binding

pub type ShaderStage = binding.WGPUShaderStage

pub struct ShaderModule {
	ptr binding.WGPUShaderModule
}

pub fn (shader ShaderModule) release() {
	C.wgpuShaderModuleRelease(shader.ptr)
}
