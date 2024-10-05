module main;

import std::io;

import graphics;
import glfw;
import webgpu;

def Window = graphics::Window;

fn void main() {

    io::printfn("launch");

    if(catch error = start()) {
        io::printfn("unexpected error: %s", error);
    }

    io::printfn("shutdown");
}

fn void! start() {

    TrackingAllocator allocator;
    allocator.init(allocator::heap());

    glfw::initialize()!;
    glfw::windowHint(glfw::window::hint::CLIENT_API, glfw::window::hint::NO_API);

    Window window;
    window.new(1000, 800, "Valdala")!;

    Renderer renderer;
    renderer.new(&window, &allocator)!;
    
    renderer.start();

    renderer.destroy();
    window.destroy();

    glfw::terminate();

    allocator.print_report();

}
