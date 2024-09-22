module graphics;

import webgpu;
import glfw_webgpu;

import std::io;

struct Surface {
    webgpu::Surface handle;
    SurfaceCapabilities capabilities;
    SurfaceConfiguration configuration;
    Device device;
    Queue queue;
    Renderer renderer;
}

fn Surface*! createSurface(Instance instance, Window* window, Allocator allocator) {

    webgpu::Surface handle = glfw_webgpu::createSurface(instance, window.handle);

    RequestAdapterOptions options;
    options.compatibleSurface = handle;
    options.powerPreference = HIGH_PERFORMANCE;

    Adapter adapter = instance.requestAdapter(&options)!;

    SurfaceCapabilities capabilities;
    handle.getCapabilities(adapter, &capabilities);

    DeviceDescriptor deviceDescriptor;
    deviceDescriptor.uncapturedErrorCallbackInfo.callback = fn void(ErrorType type, ZString message, UserData data) {
        io::printfn("uncaptured WebGPU error: %s %s", type, message);
    };

    Device device = adapter.requestDevice(&deviceDescriptor)!;
    adapter.release();

    SurfaceConfiguration configuration;
    configuration.device = device;
    configuration.format = capabilities.formats[0];
    configuration.usage = { .renderAttachment = true };
    configuration.alphaMode = OPAQUE;
    configuration.width = window.width;
    configuration.height = window.height;
    configuration.presentMode = FIFO;
    configuration.viewFormatCount = 0;

    Renderer renderer;
    renderer.clearColor = {0.9, 0.4, 0.1, 1.0};
    renderer.init(device, allocator);

    Surface* surface = allocator::alloc(allocator, Surface);
    surface.handle = handle;
    surface.capabilities = capabilities;
    surface.configuration = configuration;
    surface.renderer = renderer;
    surface.device = device;
    surface.queue = device.getQueue();

    surface.configure();

    return surface;
}

fn void Surface.destroy(&self) {

    self.renderer.destroy();

    self.handle.unconfigure();
    self.handle.release();

    self.queue.release();

    self.device.destroy();
    self.device.release();
}


fn void Surface.configure(&self) {
    self.handle.configure(&self.configuration);
}

fn void Surface.resize(&self, uint width, uint height) {

    self.configuration.width = width;
    self.configuration.height = height;

    self.configure();
}

fn void Surface.render(&self) {

    SurfaceTexture surfaceTexture;
    self.handle.getCurrentTexture(&surfaceTexture);
    Texture currentSurfaceTexture = surfaceTexture.texture;

    self.renderer.render(currentSurfaceTexture, self.device, self.handle);

    currentSurfaceTexture.release();
}

