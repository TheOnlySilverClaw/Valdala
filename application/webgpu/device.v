module webgpu

import os
import webgpu.binding

type ColorWriteMask = binding.WGPUColorWriteMask

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

pub fn (device Device) create_buffer(label string, size u32) Buffer {
	descriptor := &C.WGPUBufferDescriptor{
		label: label.str
		usage: .vertex | .copy_dst
		mappedAtCreation: 0
		size: size
	}

	buffer := C.wgpuDeviceCreateBuffer(device.ptr, descriptor)
	return Buffer{
		ptr: buffer
		size: size
	}
}

pub fn (device Device) create_render_pipeline(label string, layout PipelineLayout, vertexShader ShaderModule, fragmentShader ShaderModule, textureFormat TextureFormat) RenderPipeline {
	vertex_attributes := [
		C.WGPUVertexAttribute{
			format: .float32x2
			offset: 0
			shaderLocation: 0
		},
		C.WGPUVertexAttribute{
			format: .float32x2
			offset: 2 * sizeof(f32)
			shaderLocation: 1
		},
		C.WGPUVertexAttribute{
			format: .float32
			offset: (2 + 2) * sizeof(f32)
			shaderLocation: 2
		},
	]

	targets := [
		C.WGPUColorTargetState{
			// TODO figure out why preferred texture format shows waashed out colors
			// https://github.com/gfx-rs/wgpu-native/issues/386
			format: .bgra8_unorm
			blend: &C.WGPUBlendState{
				color: C.WGPUBlendComponent{
					srcFactor: .src_alpha
					dstFactor: .one_minus_src_alpha
					operation: .add
				}
				alpha: C.WGPUBlendComponent{
					srcFactor: .zero
					dstFactor: .one
					operation: .add
				}
			}
			writeMask: .red | .green | .blue | .alpha
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
				arrayStride: (2 + 2 + 1) * sizeof(f32)
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
		depthStencil: &C.WGPUDepthStencilState{
			format: .depth24_plus
			depthWriteEnabled: 1
			depthCompare: .less
			stencilReadMask: 0xFFFFFFFF
			stencilWriteMask: 0xFFFFFFFF
			stencilFront: C.WGPUStencilFaceState{
				compare: .always
				failOp: .keep
				depthFailOp: .keep
				passOp: .keep
			}
			stencilBack: C.WGPUStencilFaceState{
				compare: .always
				failOp: .keep
				depthFailOp: .keep
				passOp: .keep
			}
			depthBias: 1
			depthBiasSlopeScale: 0
			depthBiasClamp: 0
		}
		multisample: C.WGPUMultisampleState{
			count: 1
			mask: ~u32(0)
		}
		fragment: &C.WGPUFragmentState{
			@module: fragmentShader.ptr
			entryPoint: c'fragment'
			constants: unsafe { nil }
			targets: targets.data
			targetCount: usize(targets.len)
		}
	}

	pipeline := C.wgpuDeviceCreateRenderPipeline(device.ptr, descriptor)
	return RenderPipeline{
		ptr: pipeline
	}
}

pub fn (device Device) create_bindgroup_layout() BindGroupLayout {
	sampler_entry := C.WGPUBindGroupLayoutEntry{
		binding: 0
		visibility: .fragment
		sampler: C.WGPUSamplerBindingLayout{
			@type: .filtering
		}
	}

	texture_entry := C.WGPUBindGroupLayoutEntry{
		binding: 1
		visibility: .fragment
		texture: C.WGPUTextureBindingLayout{
			sampleType: .float
			viewDimension: ._2d
			multisampled: 0
		}
	}

	// buffer_entry := C.WGPUBindGroupLayoutEntry{
	// 	binding: 0
	// 	visibility: int(ShaderStage.vertex)
	// 	buffer: C.WGPUBufferBindingLayout{
	// 		@type: .uniform
	// 	}
	// }

	entries := [
		sampler_entry,
		texture_entry,
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

pub fn (device Device) create_bindgroup(label string, layout BindGroupLayout, buffer Buffer, sampler Sampler, texture_view TextureView) BindGroup {
	sampler_entry := C.WGPUBindGroupEntry{
		binding: 0
		sampler: sampler.ptr
	}

	texture_entry := C.WGPUBindGroupEntry{
		binding: 1
		textureView: texture_view.ptr
	}

	entries := [
		sampler_entry,
		texture_entry,
	]

	descriptor := &C.WGPUBindGroupDescriptor{
		label: label.str
		layout: layout.ptr
		entries: entries.data
		entryCount: usize(entries.len)
	}

	bind_group := C.wgpuDeviceCreateBindGroup(device.ptr, descriptor)
	return BindGroup{
		ptr: bind_group
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

@[params]
pub struct TextureOptions {
pub:
	label string
	// TODO clarify why redeclared types don't work as flag?
	usage        binding.WGPUTextureUsage
	dimension    TextureDimension = ._2d
	width        u32
	height       u32
	layers       u32 = 1
	format       TextureFormat
	mip_levels   u32 = 1
	samples      u32 = 1
	view_formats []TextureFormat
}

pub fn (device Device) create_texture(options TextureOptions) Texture {
	descriptor := &C.WGPUTextureDescriptor{
		label: options.label.str
		usage: options.usage
		dimension: options.dimension
		size: C.WGPUExtent3D{
			width: options.width
			height: options.height
			depthOrArrayLayers: options.layers
		}
		format: options.format
		mipLevelCount: options.mip_levels
		sampleCount: options.samples
		viewFormats: options.view_formats.data
		viewFormatCount: usize(options.view_formats.len)
	}

	texture := C.wgpuDeviceCreateTexture(device.ptr, descriptor)
	return Texture{
		ptr: texture
	}
}

pub fn (device Device) release() {
	C.wgpuDeviceRelease(device.ptr)
}
