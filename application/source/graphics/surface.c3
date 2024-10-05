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

fn void! Surface.new(&self, Instance instance, Window* window, Allocator allocator) {

    webgpu::Surface handle = glfw_webgpu::createSurface(instance, window.handle)!;

    RequestAdapterOptions options = {
        .compatibleSurface = handle,
        .powerPreference = HIGH_PERFORMANCE
    };

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

    SurfaceConfiguration configuration = {
        .device = device,
        .format = colorTextureFormat,
        .usage = { .renderAttachment = true },
        .alphaMode = OPAQUE,
        .width = window.width,
        .height = window.height,
        .presentMode = FIFO,
        .viewFormatCount = 0,
    };

    Renderer renderer;
    renderer.clearColor = {0.3, 0.4, 0.6, 1.0};
    renderer.new(device, queue, colorTextureFormat, depthTextureFormat, allocator)!;

    self.handle = handle;
    self.capabilities = capabilities;
    self.configuration = configuration;
    self.renderer = renderer;
    self.device = device;
    self.queue = queue;
    self.projection = MATRIX4_IDENTITY;
    self.depthTexture = createDepthTexture(device, depthTextureFormat, window.width, window.height);

    self.configure();
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
    Texture colorTexture = surfaceTexture.texture;

    Texture depthTexture = self.depthTexture;

    TextureView colorTextureView = colorTexture.createView();
    TextureView depthTextureView = depthTexture.createView();

    self.renderer.render(colorTextureView, depthTextureView, self.device, self.queue, self.projection);
    self.handle.present();

    colorTextureView.release();
    depthTextureView.release();
    colorTexture.release();
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