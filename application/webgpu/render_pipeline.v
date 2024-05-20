module webgpu

import webgpu.binding

pub struct RenderPipeline {
	ptr binding.WGPURenderPipeline
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

pub fn (pipeline RenderPipeline) release() {
	C.wgpuRenderPipelineRelease(pipeline.ptr)
}
