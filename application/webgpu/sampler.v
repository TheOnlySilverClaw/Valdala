module webgpu

import webgpu.binding

pub type AddressMode = binding.WGPUAddressMode
pub type FilterMode = binding.WGPUFilterMode

pub struct Sampler {
	ptr binding.WGPUSampler
}

@[params]
pub struct SamplerOptions {
	label          string
	address_mode_u AddressMode
	address_mode_v AddressMode
	address_mode_w AddressMode
	mag_filter     FilterMode
	min_filter     FilterMode
	mipmap_filter  FilterMode
	lod_min_clamp  f32 = 0.0
	lod_max_clamp  f32 = 1.0
	compare        binding.WGPUCompareFunction = .undefined
	max_anisotropy u16 = 1
}

pub fn (device Device) create_sampler(options SamplerOptions) Sampler {
	descriptor := &C.WGPUSamplerDescriptor{
		label: options.label.str
		addressModeU: options.address_mode_u
		addressModeV: options.address_mode_v
		addressModeW: options.address_mode_w
		magFilter: options.mag_filter
		minFilter: options.min_filter
		mipmapFilter: options.mipmap_filter
		lodMinClamp: options.lod_min_clamp
		lodMaxClamp: options.lod_max_clamp
		compare: options.compare
		maxAnisotropy: options.max_anisotropy
	}

	sampler := C.wgpuDeviceCreateSampler(device.ptr, descriptor)
	return Sampler{
		ptr: sampler
	}
}
