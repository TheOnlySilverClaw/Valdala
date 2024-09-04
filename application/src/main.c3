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

    Surface surface = glfw_webgpu::createSurface(instance, window);

    while(!window.shouldClose()) {
        glfw::pollEvents();
    }
}
