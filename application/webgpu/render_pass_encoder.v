module webgpu

import webgpu.binding

pub struct RenderPassEncoder {
	ptr binding.WGPURenderPassEncoder
}

pub fn (encoder RenderPassEncoder) end() {
	C.wgpuRenderPassEncoderEnd(encoder.ptr)
}

pub fn (encoder RenderPassEncoder) release() {
	C.wgpuRenderPassEncoderRelease(encoder.ptr)
}