module webgpu

import webgpu.binding

pub type TextureFormat = binding.WGPUTextureFormat
pub type TextureDimension = binding.WGPUTextureViewDimension
pub type TextureAspect = binding.WGPUTextureAspect

pub struct Texture {
	ptr binding.WGPUTexture
}

pub struct TextureView {
	ptr binding.WGPUTextureView
}

@[params]
pub struct TextureViewOptions {
	label string
	format TextureFormat
	dimension TextureDimension
	base_mip_level u32
	mip_levels u32 = 1
	base_array_layer u32
	array_layers u32 = 1
	aspect TextureAspect
}

pub fn (texture Texture) get_view(options TextureViewOptions) TextureView {
	descriptor := &C.WGPUTextureViewDescriptor{
		label: options.label.str,
		format: options.format,
		dimension: options.dimension,
		baseMipLevel: options.base_mip_level,
		mipLevelCount: options.mip_levels,
		baseArrayLayer: options.base_array_layer,
		arrayLayerCount: options.array_layers,
		aspect: options.aspect
	}
	view := C.wgpuTextureCreateView(texture.ptr, descriptor)
	return TextureView{
		ptr: view
	}
}

pub fn (view TextureView) release() {
	C.wgpuTextureViewRelease(view.ptr)
}

pub fn (texture Texture) release() {
	C.wgpuTextureRelease(texture.ptr)
}
