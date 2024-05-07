module binding

pub fn C.wgpuDeviceGetQueue(device WGPUDevice) WGPUQueue

pub fn C.wgpuDeviceCreateCommandEncoder(device WGPUDevice, descriptor &C.WGPUCommandEncoderDescriptor) WGPUCommandEncoder

pub fn C.wgpuDeviceCreatePipelineLayout(device WGPUDevice, descriptor &C.WGPUPipelineLayoutDescriptor) WGPUPipelineLayout

pub fn C.wgpuDeviceCreateRenderPipeline(device WGPUDevice, descriptor &C.WGPURenderPipelineDescriptor) WGPURenderPipeline

pub fn C.wgpuDeviceSetUncapturedErrorCallback(device WGPUDevice, callback WGPUErrorCallback, userdata voidptr)

pub fn C.wgpuDeviceRelease(device WGPUDevice)