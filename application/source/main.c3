import std::io;

import glfw;
import webgpu;
import glfw_webgpu;
import log;

fn void main() {


    ConsoleLogger log = { DEBUG, io::stderr() };

    log.info("launch");

    if(catch error = start()) {
        log.fatal("unexpected error", &error);
    }

    log.info("shutdown");
}

fn void! start() {

    glfw::initialize()!;
    defer glfw::terminate();

    Window window = glfw::window::createWindow(1000, 800, "Valdala");
    defer window.destroy();

    Instance instance = webgpu::createInstance();
    defer instance.release();

    Surface surface = glfw_webgpu::createSurface(instance, window);
    defer surface.release();

    RequestAdapterOptions options;
    options.compatibleSurface = surface;
    options.powerPreference = HIGH_PERFORMANCE;

    Adapter adapter = instance.requestAdapter(&options)!;
    defer adapter.release();

    TextureFormat surfaceFormat = surface.getPreferredFormat(adapter);
    io::printfn("preferred surface texture format: %s", surfaceFormat);

    Device device = adapter.requestDevice()!;
    defer {
        device.destroy();
        device.release();
    }

    Queue queue = device.getQueue();
    defer queue.release();

    while(!window.shouldClose()) {
        glfw::pollEvents();
    }
}
