module binding

pub fn C.wgpuTextureViewRelease(view WGPUTextureView)

pub type WGPUTextureView = voidptr

pub struct C.WGPUTextureViewDescriptor {
pub:
	nextInChain     &C.WGPUChainedStruct = unsafe { nil }
	label           &char
	format          WGPUTextureFormat
	dimension       WGPUTextureViewDimension
	baseMipLevel    u32
	mipLevelCount   u32
	baseArrayLayer  u32
	arrayLayerCount u32
	aspect          WGPUTextureAspect
}

pub enum WGPUTextureViewDimension {
	undefined  = 0
	_1d        = 1
	_2d        = 2
	array_2d   = 3
	cube       = 4
	array_cube = 5
	single_3d  = 6
}
