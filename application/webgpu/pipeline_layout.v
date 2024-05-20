module webgpu

import webgpu.binding

pub struct PipelineLayout {
	ptr binding.WGPUPipelineLayout
}

pub fn (device Device) create_pipeline_layout(bindgroupLayout ...BindGroupLayout) PipelineLayout {
	bind_group_layout_pointers := bindgroupLayout.map(it.ptr)

	descriptor := &C.WGPUPipelineLayoutDescriptor{
		label: unsafe { nil }
		bindGroupLayouts: bind_group_layout_pointers.data
		bindGroupLayoutCount: usize(bind_group_layout_pointers.len)
	}

	layout := C.wgpuDeviceCreatePipelineLayout(device.ptr, descriptor)
	return PipelineLayout{
		ptr: layout
	}
}
