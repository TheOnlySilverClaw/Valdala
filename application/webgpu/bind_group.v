module webgpu

import webgpu.binding

pub struct BindGroup {
	ptr binding.WGPUBindGroup
}

pub fn (bindGroup BindGroup) release() {
	C.wgpuBindGroupRelease(bindGroup.ptr)
}
