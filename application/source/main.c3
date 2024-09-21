import std::io;

import log;
import graphics;
import glfw;

def Window = graphics::Window;

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
    glfw::windowHint(glfw::window::hint::CLIENT_API, glfw::window::hint::NO_API);

    TrackingAllocator allocator;
    allocator.init(allocator::heap());

    Window* window = graphics::createWindow(1000, 800, "Valdala", &allocator)!;
    window.show();

    window.destroy();
    allocator::free(&allocator, window);

    glfw::terminate();

    allocator.print_report();
}
