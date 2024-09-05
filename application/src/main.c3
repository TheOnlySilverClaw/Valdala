import std::io;

import glfw;
import webgpu;
import glfw_webgpu;

fn void main() {

    if(catch error = start()) {
        io::printfn("Unhandled error: %s", error);
    }
}

fn void! start() {

    io::printn("Start");

    glfw::init()!;
    defer glfw::terminate();

    glfw::Window window = glfw::createWindow(1000, 800, "Valdala");
    defer window.destroy();

    Instance instance = webgpu::createInstance();
    defer instance.release();

    Surface surface = glfw_webgpu::createSurface(instance, window);
    defer surface.release();

    Adapter adapter = instance.awaitAdapter(surface)!;
    defer adapter.release();

    TextureFormat surfaceFormat = surface.getPreferredFormat(adapter);
    io::printfn("preferred surface texture format: %s", surfaceFormat);


    while(!window.shouldClose()) {
        glfw::pollEvents();
    }
}
