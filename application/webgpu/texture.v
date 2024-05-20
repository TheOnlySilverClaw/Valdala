module webgpu

import webgpu.binding

pub type TextureFormat = binding.WGPUTextureFormat
pub type TextureDimension = binding.WGPUTextureDimension
pub type TextureViewDimension = binding.WGPUTextureViewDimension
pub type TextureAspect = binding.WGPUTextureAspect
pub type TextureUsage = binding.WGPUTextureUsage

pub struct Texture {
	ptr binding.WGPUTexture
}

@[params]
pub struct TextureOptions {
pub:
	label string
	// TODO clarify why redeclared types don't work as flag?
	usage        binding.WGPUTextureUsage
	dimension    TextureDimension = ._2d
	width        u32
	height       u32
	layers       u32 = 1
	format       TextureFormat
	mip_levels   u32 = 1
	samples      u32 = 1
	view_formats []TextureFormat
}

pub fn (device Device) create_texture(options TextureOptions) Texture {
	descriptor := &C.WGPUTextureDescriptor{
		label: options.label.str
		usage: options.usage
		dimension: options.dimension
		size: C.WGPUExtent3D{
			width: options.width
			height: options.height
			depthOrArrayLayers: options.layers
		}
		format: options.format
		mipLevelCount: options.mip_levels
		sampleCount: options.samples
		viewFormats: options.view_formats.data
		viewFormatCount: usize(options.view_formats.len)
	}

	texture := C.wgpuDeviceCreateTexture(device.ptr, descriptor)
	return Texture{
		ptr: texture
	}
}

pub fn (texture Texture) release() {
	C.wgpuTextureRelease(texture.ptr)
}
