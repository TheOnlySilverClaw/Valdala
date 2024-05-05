module webgpu

import os

pub fn (device WGPUDevice) create_shader(path string, label string) !WGPUShaderModule {

	source := os.read_file(path) or {
		return error("failed to load shader $label from $path")
	}

	wgsl_desriptor := &C.WGPUShaderModuleWGSLDescriptor {
		code: source.str,
		chain: C.WGPUChainedStruct {
			next: unsafe { nil },
			sType: .shader_module_wgsl_descriptor
		}
	}

	module_descriptor := &C.WGPUShaderModuleDescriptor {
		nextInChain: &wgsl_desriptor.chain,
		label: c"test",
		hints: unsafe { nil },
		hintCount: 0
	}

	shader_module := C.wgpuDeviceCreateShaderModule(device, module_descriptor)
	return shader_module
}
