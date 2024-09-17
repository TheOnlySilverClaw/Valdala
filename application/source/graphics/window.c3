module graphics;

import glfw;
import webgpu;
import glfw_webgpu;

def GlfwHandle = glfw::window::Window;

struct Window {
    GlfwHandle handle;
}

fn void! showWindow(int width, int height, String title) {

    glfw::initialize()!;
    defer glfw::terminate();

    GlfwHandle handle = glfw::window::createWindow(width, height, title.zstr_tcopy());
    defer handle.destroy();

    Instance instance = webgpu::createInstance();
    defer instance.release();

    Surface surface = glfw_webgpu::createSurface(instance, handle);
    defer surface.release();

    RequestAdapterOptions options;
    options.compatibleSurface = surface;
    options.powerPreference = HIGH_PERFORMANCE;

    Adapter adapter = instance.requestAdapter(&options)!;
    defer adapter.release();

    TextureFormat surfaceFormat = surface.getPreferredFormat(adapter);

    Device device = adapter.requestDevice()!;
    defer {
        device.destroy();
        device.release();
    }

    Queue queue = device.getQueue();
    defer queue.release();

    while(!handle.shouldClose()) {
        glfw::pollEvents();
    }
}
