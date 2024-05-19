module binding

pub fn C.wgpuBindGroupLayoutRelease(layout WGPUBindGroupLayout)

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

pub enum WGPUBufferBindingType {
	undefined         = 0
	uniform           = 1
	storage           = 2
	read_only_storage = 3
}

pub enum WGPUSamplerBindingType {
	undefined     = 0
	filtering     = 1
	non_filtering = 2
	comparison    = 3
}

pub enum WGPUTextureSampleType {
	undefined          = 0
	float              = 1
	unfilterable_float = 2
	depth              = 3
	sint               = 4
	uint               = 5
}

pub enum WGPUStorageTextureAccess {
	undefined  = 0
	write_only = 1
	read_only  = 2
	read_write = 3
}

@[flag]
pub enum WGPUShaderStage {
	vertex
	fragment
	compute
}
