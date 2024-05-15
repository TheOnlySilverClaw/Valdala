module webgpu

import webgpu.binding

pub struct BindGroup {
	ptr binding.WGPUBindGroup
}

pub struct BindGroupLayout {
	ptr binding.WGPUBindGroupLayout
}

pub fn (layout BindGroupLayout) release() {
	C.wgpuBindGroupLayoutRelease(layout.ptr)
}
