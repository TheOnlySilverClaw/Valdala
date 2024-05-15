module webgpu

import webgpu.binding

pub struct RenderPipeline {
	ptr binding.WGPURenderPipeline
}

pub fn (pipeline RenderPipeline) release() {
	C.wgpuRenderPipelineRelease(pipeline.ptr)
}