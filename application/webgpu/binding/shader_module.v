module binding

pub struct C.WGPUShaderModuleDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct
	label       &char
	hintCount   usize
	hints       &C.WGPUShaderModuleCompilationHint
}

pub struct C.WGPUShaderModuleWGSLDescriptor {
pub:
	chain C.WGPUChainedStruct
	code  &char
}

pub struct C.WGPUShaderModuleCompilationHint {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	entryPoint  &char
	layout      WGPUPipelineLayout
}

pub fn C.wgpuDeviceCreateShaderModule(device WGPUDevice, descriptor &C.WGPUShaderModuleDescriptor) WGPUShaderModule

pub fn C.wgpuShaderModuleRelease(shader WGPUShaderModule)
