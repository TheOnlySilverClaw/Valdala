module binding

pub struct C.WGPUSurfaceConfiguration {
pub:
	nextInChain     &C.WGPUChainedStruct = unsafe { nil }
	device          WGPUDevice
	format          WGPUTextureFormat
	usage           WGPUTextureUsage
	viewFormatCount usize
	viewFormats     &WGPUTextureFormat
	alphaMode       WGPUCompositeAlphaMode
	width           u32
	height          u32
	presentMode     WGPUPresentMode
}

pub struct C.WGPUSurfaceCapabilities {
pub:
	nextInChain      &C.WGPUChainedStructOut = unsafe { nil }
	formatCount      usize
	formats          &WGPUTextureFormat
	presentModeCount usize
	presentModes     &WGPUPresentMode
	alphaModeCount   usize
	alphaModes       &WGPUCompositeAlphaMode
}

pub struct C.WGPUSurfaceTexture {
pub:
	texture    WGPUTexture
	suboptimal WGPUBool
	status     WGPUSurfaceGetCurrentTextureStatus
}

pub fn C.wgpuSurfaceGetCapabilities(surface WGPUSurface, adapter WGPUAdapter, &C.WGPUSurfaceCapabilities)

pub fn C.wgpuSurfaceConfigure(surface WGPUSurface, configuration &C.WGPUSurfaceConfiguration)

pub fn C.wgpuSurfaceGetPreferredFormat(surface WGPUSurface, adapter WGPUAdapter) WGPUTextureFormat

pub fn C.wgpuSurfacePresent(surface WGPUSurface)

pub fn C.wgpuSurfaceGetCurrentTexture(surface WGPUSurface, surfaceTexture &C.WGPUSurfaceTexture)

pub fn C.wgpuSurfaceRelease(adapter WGPUSurface)
