module graphics;

import webgpu;
import glfw_webgpu;

import std::io;
import std::thread;

struct Surface {
    webgpu::Surface handle;
    SurfaceCapabilities capabilities;
    SurfaceConfiguration configuration;
    Color clearColor;
    Device device;
    Queue queue;
}

fn Surface*! createSurface(Instance instance, Window* window, Allocator allocator) {

    webgpu::Surface handle = glfw_webgpu::createSurface(instance, window.handle);

    RequestAdapterOptions options;
    options.compatibleSurface = handle;
    options.powerPreference = HIGH_PERFORMANCE;

    Adapter adapter = instance.requestAdapter(&options)!;

    SurfaceCapabilities capabilities;
    handle.getCapabilities(adapter, &capabilities);

    Device device = adapter.requestDevice()!;
    adapter.release();

    Queue queue = device.getQueue();

    SurfaceConfiguration configuration;
    configuration.device = device;
    configuration.format = capabilities.formats[0];
    configuration.usage = { .renderAttachment = true };
    configuration.alphaMode = OPAQUE;
    configuration.width = window.width;
    configuration.height = window.height;
    configuration.presentMode = FIFO;
    configuration.viewFormatCount = 0;

    Surface* surface = allocator::alloc(allocator, Surface);
    surface.handle = handle;
    surface.capabilities = capabilities;
    surface.configuration = configuration;
    surface.clearColor = {0.9, 0.4, 0.1, 1.0};
    surface.device = device;
    surface.queue = queue;

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
    self.handle.configure(&self.configuration);
}

fn void Surface.resize(&self, uint width, uint height) {

    self.configuration.width = width;
    self.configuration.height = height;

    self.configure();
}

fn void Surface.render(&self) {

    thread::sleep_ms(100);

    SurfaceTexture surfaceTexture;
    self.handle.getCurrentTexture(&surfaceTexture);
    Texture currentSurfaceTexture = surfaceTexture.texture;

    TextureView surfaceTextureView = currentSurfaceTexture.createView();

    CommandEncoder commandEncoder = self.device.createCommandEncoder();

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
    renderPassEncoder.release();

    surfaceTextureView.release();

    CommandBuffer commandBuffer = commandEncoder.finish();
    commandEncoder.release();

    self.queue.submit(1, &commandBuffer);
    commandBuffer.release();

    self.handle.present();
    currentSurfaceTexture.release();
}

