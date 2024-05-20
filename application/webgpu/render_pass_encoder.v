module webgpu

import webgpu.binding

pub struct RenderPassEncoder {
	ptr binding.WGPURenderPassEncoder
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

pub fn (encoder RenderPassEncoder) end() {
	C.wgpuRenderPassEncoderEnd(encoder.ptr)
}

pub fn (encoder RenderPassEncoder) set_pipeline(pipeline RenderPipeline) {
	C.wgpuRenderPassEncoderSetPipeline(encoder.ptr, pipeline.ptr)
}

pub fn (encoder RenderPassEncoder) set_bindgroup(index int, group BindGroup) {
	C.wgpuRenderPassEncoderSetBindGroup(encoder.ptr, index, group.ptr, 0, unsafe { nil })
}

pub fn (encoder RenderPassEncoder) set_vertex_buffer(slot u32, buffer Buffer, offset u64) {
	C.wgpuRenderPassEncoderSetVertexBuffer(encoder.ptr, slot, buffer.ptr, offset, buffer.size)
}

pub fn (encoder RenderPassEncoder) draw(vertexCount u32, instanceCount u32, firstVertex u32, firstInstance u32) {
	C.wgpuRenderPassEncoderDraw(encoder.ptr, vertexCount, instanceCount, firstVertex,
		firstInstance)
}

pub fn (encoder RenderPassEncoder) release() {
	C.wgpuRenderPassEncoderRelease(encoder.ptr)
}
