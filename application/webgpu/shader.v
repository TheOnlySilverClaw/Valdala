module webgpu

import webgpu.binding

pub type ShaderStage = binding.WGPUShaderStage

pub struct ShaderModule {
	ptr binding.WGPUShaderModule
}

pub fn (device Device) create_shader(source string, label string) !ShaderModule {
	wgsl_desriptor := &C.WGPUShaderModuleWGSLDescriptor{
		code: source.str
		chain: C.WGPUChainedStruct{
			next: unsafe { nil }
			sType: .shader_module_wgsl_descriptor
		}
	}

	module_descriptor := &C.WGPUShaderModuleDescriptor{
		nextInChain: &wgsl_desriptor.chain
		label: label.str
		hints: unsafe { nil }
		hintCount: 0
	}

	shader_module := C.wgpuDeviceCreateShaderModule(device.ptr, module_descriptor)
	return ShaderModule{
		ptr: shader_module
	}
}

pub fn (shader ShaderModule) release() {
	C.wgpuShaderModuleRelease(shader.ptr)
}
