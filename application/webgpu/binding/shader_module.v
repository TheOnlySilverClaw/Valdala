module binding

pub fn C.wgpuDeviceCreateShaderModule(device WGPUDevice, descriptor &C.WGPUShaderModuleDescriptor) WGPUShaderModule

pub fn C.wgpuShaderModuleRelease(shader WGPUShaderModule)