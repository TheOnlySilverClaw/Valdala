module webgpu

import webgpu.binding

pub struct CommandEncoder {
	ptr binding.WGPUCommandEncoder
}

pub fn (encoder CommandEncoder) begin_render_pass(view TextureView) RenderPassEncoder {

	descriptor := C.WGPURenderPassDescriptor {
		label: unsafe { nil }
		colorAttachmentCount: 1,
		colorAttachments: &C.WGPURenderPassColorAttachment {
			view: view.ptr,
			resolveTarget: unsafe { nil }
			clearValue: C.WGPUColor {
				r: 0.1,
				g: 0.1,
				b: 0.1,
				a: 1.0
			},
			loadOp: .clear,
			storeOp: .store
		},
		depthStencilAttachment: unsafe { nil },
		timestampWrites: unsafe { nil }
	}

	pass_encoder := C.wgpuCommandEncoderBeginRenderPass(encoder.ptr, &descriptor)
	return RenderPassEncoder { ptr: pass_encoder }
}

pub fn (encoder CommandEncoder) finish() CommandBuffer {
	
	descriptor := C.WGPUCommandBufferDescriptor {
		label: unsafe { nil }
	}

	buffer := C.wgpuCommandEncoderFinish(encoder.ptr, &descriptor)
	return CommandBuffer { ptr: buffer }
}

pub fn (encoder CommandEncoder) release() {
	C.wgpuCommandEncoderRelease(encoder.ptr)
}