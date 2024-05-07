module binding

pub fn C.wgpuTextureCreateView(texture WGPUTexture, descriptor &C.WGPUTextureViewDescriptor) WGPUTextureView

pub fn C.wgpuTextureRelease(texture WGPUTexture)

pub fn C.wgpuTextureViewRelease(view WGPUTextureView)
