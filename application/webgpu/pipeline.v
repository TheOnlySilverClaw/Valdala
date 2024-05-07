module webgpu

import webgpu.binding

pub struct RenderPipeline {
	ptr binding.WGPURenderPipeline
}

pub struct PipelineLayout {
	ptr binding.WGPUPipelineLayout
}