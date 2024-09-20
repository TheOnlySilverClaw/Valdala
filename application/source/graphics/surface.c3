module graphics;

import webgpu;
import glfw_webgpu;

import std::io;
import std::thread;

struct Surface {
    webgpu::Surface handle;
    TextureFormat textureFormat;
    Color clearColor;
    Device device;
    Queue queue;
    uint width;
    uint height;
}

fn Surface*! createSurface(Instance instance, Window* window) {

    webgpu::Surface handle = glfw_webgpu::createSurface(instance, window.handle);

    RequestAdapterOptions options;
    options.compatibleSurface = handle;
    options.powerPreference = HIGH_PERFORMANCE;

    Adapter adapter = instance.requestAdapter(&options)!;

    SurfaceCapabilities capabilities;
    handle.getCapabilities(adapter, &capabilities);

    io::printfn("formats: %s", capabilities.formatCount);

    for(int i = 0; i < capabilities.formatCount; i++) {
        TextureFormat format = capabilities.formats[i];
        io::printfn("format: %s", format);
    }
    TextureFormat surfaceFormat = capabilities.formats[0];

    Device device = adapter.requestDevice()!;
    adapter.release();

    Queue queue = device.getQueue();

    Color clearColor;
    clearColor.red = 0.2;
    clearColor.green = 0.2;
    clearColor.blue = 0.4;
    clearColor.alpha = 1.0;

    Surface* surface = allocator::alloc(allocator::heap(), Surface);
    surface.handle = handle;
    surface.textureFormat = surfaceFormat;
    surface.clearColor = clearColor;
    surface.device = device;
    surface.queue = queue;
    surface.width = window.width;
    surface.height = window.height;
    surface.configure();

    return surface;
}

fn void Surface.destroy(&self) {

    self.queue.release();

    self.handle.unconfigure();
    self.handle.release();

    self.device.destroy();
    self.device.release();
}


fn void Surface.configure(&self) {

    TextureUsage textureUsage = { .renderAttachment = true };

    SurfaceConfiguration configuration;
    configuration.device = self.device;
    configuration.format = self.textureFormat;
    configuration.usage = textureUsage;
    configuration.alphaMode = OPAQUE;
    configuration.width = self.width;
    configuration.height = self.height;
    configuration.presentMode = FIFO;

    self.handle.configure(&configuration);
}

fn void Surface.resize(&self, uint width, uint height) {

    self.width = width;
    self.height = height;
    self.configure();
}

fn void Surface.render(&self) {

    thread::sleep_ms(1);

    SurfaceTexture surfaceTexture;
    self.handle.getCurrentTexture(&surfaceTexture);
    Texture currentSurfaceTexture = surfaceTexture.texture;
    defer currentSurfaceTexture.release();

    TextureView surfaceTextureView = currentSurfaceTexture.createView();
    defer surfaceTextureView.release();

    CommandEncoder commandEncoder = self.device.createCommandEncoder();
    defer commandEncoder.release();

    RenderPassColorAttachment colorAttachment;
    colorAttachment.view = surfaceTextureView;
    colorAttachment.loadOperation = CLEAR;
    colorAttachment.storeOperation = STORE;
    colorAttachment.clearValue = self.clearColor;

    RenderPassDescriptor renderPassDescriptor;
    renderPassDescriptor.colorAttachmentCount = 1;
    renderPassDescriptor.colorAttachments = &colorAttachment;

    RenderPassEncoder renderPassEncoder = commandEncoder.beginRenderPass(&renderPassDescriptor);
    renderPassEncoder.end();

    self.handle.present();
}

