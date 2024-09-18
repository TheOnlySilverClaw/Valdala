module graphics;

import webgpu;
import glfw_webgpu;

def WebGPUHandle = webgpu::Surface @private;

struct Surface {
    WebGPUHandle handle;
    TextureFormat textureFormat;
    Color clearColor;
    Adapter adapter;
    Device device;
    Queue queue;
}

fn Surface! createSurface(Instance instance, GlfwHandle glfwWindow) {

    WebGPUHandle handle = glfw_webgpu::createSurface(instance, glfwWindow);

    RequestAdapterOptions options;
    options.compatibleSurface = handle;
    options.powerPreference = HIGH_PERFORMANCE;

    Adapter adapter = instance.requestAdapter(&options)!;

    TextureFormat surfaceFormat = handle.getPreferredFormat(adapter);

    Device device = adapter.requestDevice()!;

    Queue queue = device.getQueue();

    Color clearColor;
    clearColor.red = 0.2;
    clearColor.green = 0.2;
    clearColor.blue = 0.4;
    clearColor.alpha = 1.0;

    Surface surface;
    surface.handle = handle;
    surface.textureFormat = surfaceFormat;
    surface.clearColor = clearColor;
    surface.adapter = adapter;
    surface.device = device;
    surface.queue = queue;

    return surface;
}

fn void Surface.destroy(&self) {

    self.queue.release();
    self.device.destroy();
    self.device.release();
    self.adapter.release();
    self.handle.release();
}
