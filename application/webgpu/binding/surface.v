module binding

pub fn C.wgpuSurfaceGetCapabilities(surface WGPUSurface, adapter WGPUAdapter, &C.WGPUSurfaceCapabilities)

pub fn C.wgpuSurfaceConfigure(surface WGPUSurface, configuration &C.WGPUSurfaceConfiguration)

pub fn C.wgpuSurfaceGetPreferredFormat(surface WGPUSurface, adapter WGPUAdapter) WGPUTextureFormat

pub fn C.wgpuSurfacePresent(surface WGPUSurface)

pub fn C.wgpuSurfaceGetCurrentTexture(surface WGPUSurface, surfaceTexture &C.WGPUSurfaceTexture)

pub fn C.wgpuSurfaceRelease(adapter WGPUSurface)