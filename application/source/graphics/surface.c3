module graphics;

import webgpu;
import glfw_webgpu;
import glfw::window;

import std::io;

struct Surface {
    webgpu::Surface handle;
    SurfaceCapabilities capabilities;
    SurfaceConfiguration configuration;
    Device device;
    TextureFormat depthTextureFormat;
    Texture depthTexture;
}

fn void! Surface.new(&self, Window* window, uint width, uint height, Instance instance) {

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

    SurfaceConfiguration configuration = {
        .device = device,
        .format = capabilities.formats[0],
        .usage = { .renderAttachment = true },
        .alphaMode = OPAQUE,
        .width = width,
        .height = height,
        .presentMode = FIFO,
        .viewFormatCount = 0,
    };

    self.handle = handle;
    self.capabilities = capabilities;
    self.configuration = configuration;
    self.device = device;
    self.depthTextureFormat = DEPTH24_PLUS;
    self.depthTexture = self.createDepthTexture();
    
    self.configure();
}

fn Texture Surface.createDepthTexture(&self) {

    TextureDescriptor descriptor = {
        .label = "depth",
        .usage = { .renderAttachment = true },
        .dimension = DIMENSION_2D,
        .size = {
            .width = self.width(),
            .height = self.height(),
            .depthOrArrayLayers = 1
        },
        .mipLevelCount = 1,
        .sampleCount = 1,
        .format = self.depthTextureFormat
    };

    return self.device.createTexture(&descriptor);
}

fn void Surface.configure(&self) {
    self.handle.configure(&self.configuration);
}

fn void Surface.resize(&self, uint width, uint height) {

    self.configuration.width = width;
    self.configuration.height = height;

    self.depthTexture.destroy();
    self.depthTexture.release();
    self.depthTexture = self.createDepthTexture();
    
    self.configure();
}

fn Texture Surface.current_color_texture(&self) {

    SurfaceTexture surfaceTexture;
    self.handle.getCurrentTexture(&surfaceTexture);
    return surfaceTexture.texture;
}

fn TextureFormat Surface.color_texture_format(&self) {
    return self.configuration.format;
}

fn uint Surface.width(&self) {
    return self.configuration.width;
}

fn uint Surface.height(&self) {
    return self.configuration.height;
}

fn float Surface.aspect_ratio(&self) {
    return ((float) self.width()) / ((float) self.height());
}

fn void Surface.present(&self) {
    self.handle.present();
}

fn void Surface.destroy(&self) {

    // self.capabilities.freeMembers();

    self.depthTexture.destroy();
    self.depthTexture.release();

    self.handle.unconfigure();
    self.handle.release();

    self.device.destroy();
    self.device.release();
}