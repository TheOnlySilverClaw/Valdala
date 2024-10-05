module main;

import std::io;

import graphics;
import glfw;

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
    window.new(1000, 800, "Valdala", &allocator)!;
    window.show();
    window.destroy();

    glfw::terminate();

    allocator.print_report();
}
