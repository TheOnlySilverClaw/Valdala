module binding

pub fn C.wgpuSurfaceGetCapabilities(surface WGPUSurface, adapter WGPUAdapter, &C.WGPUSurfaceCapabilities)

pub fn C.wgpuSurfaceConfigure(surface WGPUSurface, configuration &C.WGPUSurfaceConfiguration)

pub fn C.wgpuSurfaceGetPreferredFormat(surface WGPUSurface, adapter WGPUAdapter) WGPUTextureFormat

pub fn C.wgpuSurfacePresent(surface WGPUSurface)

pub fn C.wgpuSurfaceGetCurrentTexture(surface WGPUSurface, surfaceTexture &C.WGPUSurfaceTexture)

pub fn C.wgpuSurfaceRelease(adapter WGPUSurface)

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

pub enum WGPUSurfaceGetCurrentTextureStatus {
	success       = 0
	timeout       = 1
	outdated      = 2
	lost          = 3
	out_of_memory = 4
	device_lost   = 5
}

pub enum WGPUCompositeAlphaMode {
	auto            = 0
	opaque          = 1
	premultiplied   = 2
	unpremultiplied = 3
	inherit         = 4
}

pub enum WGPUPresentMode {
	fifo         = 0
	fifo_relaxed = 1
	immediate    = 2
	mailbox      = 3
}
