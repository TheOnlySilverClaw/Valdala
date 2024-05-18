module binding

pub struct C.WGPUTextureDescriptor {
pub:
	nextInChain     &C.WGPUChainedStruct = unsafe { nil }
	label           &char
	usage           WGPUTextureUsage
	dimension       WGPUTextureDimension
	size            C.WGPUExtent3D
	format          WGPUTextureFormat
	mipLevelCount   u32
	sampleCount     u32
	viewFormatCount usize
	viewFormats     &WGPUTextureFormat
}

pub struct C.WGPUExtent3D {
pub:
	width              u32
	height             u32
	depthOrArrayLayers u32
}

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

pub fn C.wgpuTextureCreateView(texture WGPUTexture, descriptor &C.WGPUTextureViewDescriptor) WGPUTextureView

pub fn C.wgpuTextureRelease(texture WGPUTexture)

pub fn C.wgpuTextureViewRelease(view WGPUTextureView)
