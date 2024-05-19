module binding

pub fn C.wgpuSamplerRelease(sampler WGPUSampler)

pub type WGPUSampler = voidptr

pub struct C.WGPUSamplerDescriptor {
pub:
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	label         &char
	addressModeU  WGPUAddressMode
	addressModeV  WGPUAddressMode
	addressModeW  WGPUAddressMode
	magFilter     WGPUFilterMode
	minFilter     WGPUFilterMode
	mipmapFilter  WGPUFilterMode
	lodMinClamp   f32
	lodMaxClamp   f32
	compare       WGPUCompareFunction
	maxAnisotropy u16
}

pub enum WGPUAddressMode {
	repeat        = 0
	mirror_repeat = 1
	clamp_to_edge = 2
}

pub enum WGPUFilterMode {
	nearest = 0
	linear  = 1
}
