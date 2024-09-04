import std::io;
import glfw;

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

    while(!window.shouldClose()) {
        glfw::pollEvents();
    }
}
