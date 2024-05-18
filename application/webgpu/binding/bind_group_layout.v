module binding

pub struct C.WGPUBindGroupLayoutDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
	entryCount  usize
	entries     &C.WGPUBindGroupLayoutEntry
}

pub struct C.WGPUBindGroupLayoutEntry {
pub:
	nextInChain    &C.WGPUChainedStruct = unsafe { nil }
	binding        u32
	visibility     WGPUShaderStage
	buffer         C.WGPUBufferBindingLayout
	sampler        C.WGPUSamplerBindingLayout
	texture        C.WGPUTextureBindingLayout
	storageTexture C.WGPUStorageTextureBindingLayout
}

pub struct C.WGPUBufferBindingLayout {
pub:
	nextInChain      &C.WGPUChainedStruct = unsafe { nil }
	@type            WGPUBufferBindingType
	hasDynamicOffset WGPUBool
	minBindingSize   u64
}

pub struct C.WGPUSamplerBindingLayout {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	@type       WGPUSamplerBindingType
}

pub struct C.WGPUTextureBindingLayout {
pub:
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	sampleType    WGPUTextureSampleType
	viewDimension WGPUTextureViewDimension
	multisampled  WGPUBool
}

pub struct C.WGPUStorageTextureBindingLayout {
pub:
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	access        WGPUStorageTextureAccess
	format        WGPUTextureFormat
	viewDimension WGPUTextureViewDimension
}

pub fn C.wgpuBindGroupLayoutRelease(layout WGPUBindGroupLayout)
