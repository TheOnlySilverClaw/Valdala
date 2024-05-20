module webgpu

import webgpu.binding

pub struct BindGroup {
	ptr binding.WGPUBindGroup
}

pub fn (device Device) create_bindgroup(label string, layout BindGroupLayout, buffer Buffer, sampler Sampler, texture_view TextureView) BindGroup {
	sampler_entry := C.WGPUBindGroupEntry{
		binding: 0
		sampler: sampler.ptr
	}

	texture_entry := C.WGPUBindGroupEntry{
		binding: 1
		textureView: texture_view.ptr
	}

	entries := [
		sampler_entry,
		texture_entry,
	]

	descriptor := &C.WGPUBindGroupDescriptor{
		label: label.str
		layout: layout.ptr
		entries: entries.data
		entryCount: usize(entries.len)
	}

	bind_group := C.wgpuDeviceCreateBindGroup(device.ptr, descriptor)
	return BindGroup{
		ptr: bind_group
	}
}

pub fn (bindGroup BindGroup) release() {
	C.wgpuBindGroupRelease(bindGroup.ptr)
}
