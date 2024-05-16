module webgpu

import os
import webgpu.binding

pub struct Device {
	ptr binding.WGPUDevice
}

pub fn (device Device) get_queue() Queue {
	queue := C.wgpuDeviceGetQueue(device.ptr)
	return Queue{
		ptr: queue
	}
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

pub fn (device Device) create_pipeline_layout(bindgroupLayout ...BindGroupLayout) PipelineLayout {
	bind_group_layout_pointers := bindgroupLayout.map(it.ptr)

	descriptor := &C.WGPUPipelineLayoutDescriptor{
		label: unsafe { nil }
		bindGroupLayouts: bind_group_layout_pointers.data
		bindGroupLayoutCount: usize(bind_group_layout_pointers.len)
	}

	layout := C.wgpuDeviceCreatePipelineLayout(device.ptr, descriptor)
	return PipelineLayout{
		ptr: layout
	}
}

pub fn (device Device) create_render_pipeline(label string, layout PipelineLayout, vertexShader ShaderModule, fragmentShader ShaderModule) RenderPipeline {
	vertex_attributes := [
		C.WGPUVertexAttribute{
			format: .float32x2
			offset: 0
			shaderLocation: 0
		},
		C.WGPUVertexAttribute{
			format: .float32x4
			offset: 2 * sizeof(f32)
			shaderLocation: 1
		},
	]

	descriptor := &C.WGPURenderPipelineDescriptor{
		label: label.str
		layout: layout.ptr
		vertex: C.WGPUVertexState{
			@module: vertexShader.ptr
			entryPoint: c'vertex'
			constants: unsafe { nil }
			buffers: &C.WGPUVertexBufferLayout{
				arrayStride: (2 + 4) * sizeof(f32)
				stepMode: .vertex
				attributes: vertex_attributes.data
				attributeCount: usize(vertex_attributes.len)
			}
			bufferCount: 1
		}
		primitive: C.WGPUPrimitiveState{
			topology: .triangle_list
			frontFace: .ccw
			cullMode: .@none
		}
		depthStencil: unsafe { nil }
		multisample: C.WGPUMultisampleState{
			count: 1
		}
		fragment: &C.WGPUFragmentState{
			@module: fragmentShader.ptr
			entryPoint: c'fragment'
			constants: unsafe { nil }
			targets: unsafe { nil }
		}
	}

	pipeline := C.wgpuDeviceCreateRenderPipeline(device.ptr, descriptor)
	return RenderPipeline{
		ptr: pipeline
	}
}

pub fn (device Device) create_bindgroup_layout() BindGroupLayout {
	buffer_entry := C.WGPUBindGroupLayoutEntry{
		binding: 0
		visibility: int(ShaderStage.vertex)
		buffer: C.WGPUBufferBindingLayout{
			@type: .uniform
		}
	}

	entries := [
		buffer_entry,
	]

	descriptor := &C.WGPUBindGroupLayoutDescriptor{
		label: unsafe { nil }
		entries: entries.data
		entryCount: usize(entries.len)
	}

	layout := C.wgpuDeviceCreateBindGroupLayout(device.ptr, descriptor)

	return BindGroupLayout{
		ptr: layout
	}
}

pub fn (device Device) create_shader(path string, label string) !ShaderModule {
	source := os.read_file(path) or { return error('failed to load shader ${label} from ${path}') }

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

pub fn (device Device) release() {
	C.wgpuDeviceRelease(device.ptr)
}
