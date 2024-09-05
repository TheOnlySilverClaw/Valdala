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

    foreach (FeatureName feature : FeatureName.values) {
        bool available = adapter.hasFeature(feature) == 1;
        io::printfn("feature %s %s", feature, available);
    }


    while(!window.shouldClose()) {
        glfw::pollEvents();
    }
}
