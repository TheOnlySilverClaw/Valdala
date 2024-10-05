module graphics;

import webgpu;
import glfw_webgpu;

import std::io;
import std::math::matrix;

struct Surface {
    webgpu::Surface handle;
    SurfaceCapabilities capabilities;
    SurfaceConfiguration configuration;
    Device device;
    Queue queue;
    Renderer renderer;
    Matrix4 projection;
    Texture depthTexture;
}

fn Surface*! createSurface(Instance instance, Window* window, Allocator allocator) {

    webgpu::Surface handle = glfw_webgpu::createSurface(instance, window.handle)!;

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

	Queue queue = device.getQueue();
	
    TextureFormat colorTextureFormat = capabilities.formats[0];
    TextureFormat depthTextureFormat = DEPTH24_PLUS;

    SurfaceConfiguration configuration;
    configuration.device = device;
    configuration.format = colorTextureFormat;
    configuration.usage = { .renderAttachment = true };
    configuration.alphaMode = OPAQUE;
    configuration.width = window.width;
    configuration.height = window.height;
    configuration.presentMode = FIFO;
    configuration.viewFormatCount = 0;

    Renderer renderer;
    renderer.clearColor = {0.3, 0.4, 0.6, 1.0};
    renderer.init(device, queue, colorTextureFormat, depthTextureFormat, allocator)!;

    Surface* surface = allocator::alloc(allocator, Surface);
    surface.handle = handle;
    surface.capabilities = capabilities;
    surface.configuration = configuration;
    surface.renderer = renderer;
    surface.device = device;
    surface.queue = queue;
    surface.projection = MATRIX4_IDENTITY;
    surface.depthTexture = createDepthTexture(device, depthTextureFormat, window.width, window.height);

    surface.configure();

    return surface;
}

fn Texture createDepthTexture(Device device, TextureFormat format, uint width, uint height) {

    TextureDescriptor descriptor = {
        .label = "depth",
        .usage = { .renderAttachment = true },
        .dimension = DIMENSION_2D,
        .size = {
            .width = width,
            .height = height,
            .depthOrArrayLayers = 1
        },
        .mipLevelCount = 1,
        .sampleCount = 1,
        .format = format
    };

    return device.createTexture(&descriptor);
}

fn void Surface.configure(&self) {
    self.handle.configure(&self.configuration);
}

fn void Surface.resize(&self, uint width, uint height) {

    self.configuration.width = width;
    self.configuration.height = height;

    Texture old = self.depthTexture;
    TextureFormat format = old.getFormat();
    old.destroy();
    old.release();

    self.depthTexture = createDepthTexture(self.device, format, width, height);

    self.configure();
}

fn void Surface.render(&self) {

    SurfaceTexture surfaceTexture;
    self.handle.getCurrentTexture(&surfaceTexture);
    Texture currentSurfaceTexture = surfaceTexture.texture;

    self.renderer.render(currentSurfaceTexture, self.depthTexture, self.device, self.queue, self.projection);
    self.handle.present();

    currentSurfaceTexture.release();
}

fn void Surface.destroy(&self) {

    self.renderer.destroy();

    self.depthTexture.destroy();
    self.depthTexture.release();

    self.handle.unconfigure();
    self.handle.release();

    self.queue.release();

    self.device.destroy();
    self.device.release();
}