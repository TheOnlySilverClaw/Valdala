module webgpu

import webgpu.binding

pub type TextureFormat = binding.WGPUTextureFormat

pub struct Texture {
	ptr binding.WGPUTexture
}

pub struct TextureView {
	ptr binding.WGPUTextureView
}

pub fn (texture Texture) get_view(mip_levels u32) TextureView {
	descriptor := &C.WGPUTextureViewDescriptor{
		label: unsafe { nil }
		mipLevelCount: mip_levels,
		arrayLayerCount: 1,
		aspect: .all
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
