module webgpu

fn C.wgpuGetVersion() int

fn C.wgpuCreateInstance(descriptor &C.WGPUInstanceDescriptor) WGPUInstance

fn C.wgpuInstanceRelease(instance WGPUInstance)

fn C.wgpuInstanceRequestAdapter(instance WGPUInstance, options &C.WGPURequestAdapterOptions, callback WGPURequestAdapterCallback, user_data voidptr)

fn C.wgpuAdapterRelease(adapter WGPUAdapter)

fn C.wgpuDeviceRelease(device WGPUDevice)

fn C.wgpuSurfaceRelease(adapter WGPUSurface)

fn C.wgpuAdapterRequestDevice(adapter WGPUAdapter, descriptor &C.WGPUDeviceDescriptor, callback WGPURequestDeviceCallback, user_data voidptr)

fn C.wgpuDeviceSetUncapturedErrorCallback(device WGPUDevice, callback WGPUErrorCallback, userdata voidptr)

fn C.wgpuDeviceGetQueue(device WGPUDevice) WGPUQueue

fn C.wgpuQueueRelease(queue WGPUQueue)

fn C.wgpuQueueSubmit(queue WGPUQueue, command_count usize, commands &WGPUCommandBuffer)

fn C.wgpuDeviceCreateCommandEncoder(device WGPUDevice, descriptor &C.WGPUCommandEncoderDescriptor) WGPUCommandEncoder

fn C.wgpuCommandEncoderRelease(encoder WGPUCommandEncoder)

fn C.wgpuCommandEncoderBeginRenderPass(commandEncoder WGPUCommandEncoder, descriptor &C.WGPURenderPassDescriptor) WGPURenderPassEncoder

fn C.wgpuCommandEncoderFinish(encoder WGPUCommandEncoder, descriptor &C.WGPUCommandBufferDescriptor) WGPUCommandBuffer

fn C.wgpuCommandBufferRelease(buffer WGPUCommandBuffer)

fn C.wgpuRenderPassEncoderEnd(encoder WGPURenderPassEncoder)

fn C.wgpuRenderPassEncoderRelease(encoder WGPURenderPassEncoder)

fn C.wgpuSurfaceGetCapabilities(surface WGPUSurface, adapter WGPUAdapter, &C.WGPUSurfaceCapabilities)

fn C.wgpuSurfaceConfigure(surface WGPUSurface, configuration &C.WGPUSurfaceConfiguration)

fn C.wgpuSurfacePresent(surface WGPUSurface)

fn C.wgpuSurfaceGetCurrentTexture(surface WGPUSurface, surfaceTexture &C.WGPUSurfaceTexture)

fn C.wgpuTextureCreateView(texture WGPUTexture, descriptor &C.WGPUTextureViewDescriptor) WGPUTextureView

fn C.wgpuTextureRelease(texture WGPUTexture)

fn C.wgpuTextureViewRelease(view WGPUTextureView)