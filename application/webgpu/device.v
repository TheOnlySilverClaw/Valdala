module webgpu

import os

import webgpu.binding

pub struct Device {
	ptr binding.WGPUDevice
}

pub fn (device Device) get_queue() Queue {
	queue := C.wgpuDeviceGetQueue(device.ptr)
	return Queue { ptr : queue }
}

pub fn (device Device) create_command_encoder(label string) CommandEncoder {

	descriptor := C.WGPUCommandEncoderDescriptor {
		label: label.str
	}
	encoder := C.wgpuDeviceCreateCommandEncoder(device.ptr, &descriptor)
	return CommandEncoder { ptr : encoder }
}

pub fn (device Device) create_pipeline_layout() {

}

pub fn (device Device) create_render_pipeline(label string, layout PipelineLayout) {

	// descriptor := C.WGPURenderPipelineDescriptor {
	// 	label: label.str,
	// 	layout       WGPUPipelineLayout
	// 	vertex       C.WGPUVertexState
	// 	primitive    C.WGPUPrimitiveState
	// 	depthStencil &C.WGPUDepthStencilState
	// 	multisample  C.WGPUMultisampleState
	// 	fragment     C.WGPUFragmentState
	// }

	// return C.wgpuDeviceCreateRenderPipeline(device)
}


pub fn (device Device) create_shader(path string, label string) !ShaderModule {

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
		label: label.str,
		hints: unsafe { nil },
		hintCount: 0
	}

	shader_module := C.wgpuDeviceCreateShaderModule(device.ptr, module_descriptor)
	return ShaderModule { ptr : shader_module }
}

pub fn (device Device) release() {
	C.wgpuDeviceRelease(device.ptr)
}