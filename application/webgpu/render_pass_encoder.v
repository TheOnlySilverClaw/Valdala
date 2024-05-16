module webgpu

import webgpu.binding

pub struct RenderPassEncoder {
	ptr binding.WGPURenderPassEncoder
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
