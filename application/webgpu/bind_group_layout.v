module webgpu

import webgpu.binding

pub struct BindGroupLayout {
	ptr binding.WGPUBindGroupLayout
}

pub fn (device Device) create_bindgroup_layout() BindGroupLayout {
	buffer_entry := C.WGPUBindGroupLayoutEntry{
		binding: 0
		visibility: .vertex
		buffer: C.WGPUBufferBindingLayout{
			@type: .uniform
		}
	}

	sampler_entry := C.WGPUBindGroupLayoutEntry{
		binding: 1
		visibility: .fragment
		sampler: C.WGPUSamplerBindingLayout{
			@type: .filtering
		}
	}

	texture_entry := C.WGPUBindGroupLayoutEntry{
		binding: 2
		visibility: .fragment
		texture: C.WGPUTextureBindingLayout{
			sampleType: .float
			viewDimension: ._2d
			multisampled: 0
		}
	}

	entries := [
		buffer_entry,
		sampler_entry,
		texture_entry,
	]

	descriptor := &C.WGPUBindGroupLayoutDescriptor{
		label: unsafe { nil }
		entries: entries.data
		entryCount: usize(entries.len)
	}

	layout := C.wgpuDeviceCreateBindGroupLayout(device.ptr, descriptor)

	return BindGroupLayout{
		ptr: layout
	}
}

pub fn (layout BindGroupLayout) release() {
	C.wgpuBindGroupLayoutRelease(layout.ptr)
}
