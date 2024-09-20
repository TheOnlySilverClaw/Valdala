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
    defer glfw::terminate();

    glfw::windowHint(glfw::window::hint::CLIENT_API, glfw::window::hint::NO_API);

    Window* window = graphics::createWindow(1000, 800, "Valdala")!;
    defer window.destroy();

    window.show();
}
