module webgpu

import webgpu.binding

pub struct CommandEncoder {
	ptr binding.WGPUCommandEncoder
}

pub fn (encoder CommandEncoder) begin_render_pass(frame TextureView, depthTexture TextureView) RenderPassEncoder {
	descriptor := &C.WGPURenderPassDescriptor{
		label: unsafe { nil }
		colorAttachmentCount: 1
		colorAttachments: &C.WGPURenderPassColorAttachment{
			view: frame.ptr
			resolveTarget: unsafe { nil }
			clearValue: C.WGPUColor{
				r: 0.2
				g: 0.2
				b: 0.2
				a: 1.0
			}
			loadOp: .clear
			storeOp: .store
		}
		depthStencilAttachment: &C.WGPURenderPassDepthStencilAttachment{
			view: depthTexture.ptr
			depthLoadOp: .clear
			depthStoreOp: .store
			depthClearValue: 1.0
			stencilLoadOp: .clear
			stencilStoreOp: .store
			stencilClearValue: 0
			stencilReadOnly: 1
		}
		timestampWrites: unsafe { nil }
	}

	pass_encoder := C.wgpuCommandEncoderBeginRenderPass(encoder.ptr, descriptor)
	return RenderPassEncoder{
		ptr: pass_encoder
	}
}

pub fn (encoder CommandEncoder) finish() CommandBuffer {
	descriptor := &C.WGPUCommandBufferDescriptor{
		label: unsafe { nil }
	}

	buffer := C.wgpuCommandEncoderFinish(encoder.ptr, descriptor)
	return CommandBuffer{
		ptr: buffer
	}
}

pub fn (encoder CommandEncoder) release() {
	C.wgpuCommandEncoderRelease(encoder.ptr)
}
