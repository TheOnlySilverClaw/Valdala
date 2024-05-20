module webgpu

import webgpu.binding

pub struct Surface {
pub:
	ptr binding.WGPUSurface
}

pub fn (surface Surface) get_current_texture() !Texture {
	surface_texture := C.WGPUSurfaceTexture{}

	C.wgpuSurfaceGetCurrentTexture(surface.ptr, &surface_texture)

	if surface_texture.status == .success {
		return Texture{
			ptr: surface_texture.texture
		}
	} else {
		return error('surface texture error: ${surface_texture.status}')
	}
}

pub fn (surface Surface) get_preferred_format(adapter Adapter) TextureFormat {
	return C.wgpuSurfaceGetPreferredFormat(surface.ptr, adapter.ptr)
}

pub fn (surface Surface) configure(adapter Adapter, device Device, width u32, height u32) {
	capabilities := C.WGPUSurfaceCapabilities{
		formats: unsafe { nil }
		presentModes: unsafe { nil }
		alphaModes: unsafe { nil }
	}

	C.wgpuSurfaceGetCapabilities(surface.ptr, adapter.ptr, &capabilities)

	configuration := C.WGPUSurfaceConfiguration{
		device: device.ptr
		usage: .render_attachment
		// TODO figure out why preferred texture format shows waashed out colors
		// https://github.com/gfx-rs/wgpu-native/issues/386
		format: .bgra8_unorm
		presentMode: .fifo
		alphaMode: unsafe { capabilities.alphaModes[0] }
		viewFormats: capabilities.formats
		viewFormatCount: capabilities.formatCount
		width: width
		height: height
	}

	C.wgpuSurfaceConfigure(surface.ptr, &configuration)
}

pub fn (surface Surface) present() {
	C.wgpuSurfacePresent(surface.ptr)
}

pub fn (surface Surface) release() {
	C.wgpuSurfaceRelease(surface.ptr)
}
