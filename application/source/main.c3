module main;

import std::io;
import std::thread;

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
    defer {
        allocator.print_report();
        allocator.free();
    }

    mem::@scoped(&allocator) {

        glfw::initialize()!;
        glfw::windowHint(glfw::window::hint::CLIENT_API, glfw::window::hint::NO_API);
        defer glfw::terminate();
    
        Window* window = Window{}.init(1000, 800, "Valdala")!;
        defer window.destroy();
    
        Camera camera;
    
        Renderer* renderer = Renderer{}.init(&window.surface, &camera)!;
        defer renderer.destroy();
        
        window.setup_input(&camera);
    
        while(window.keep_open()) {
            glfw::pollEvents();
            renderer.render()!;
            thread::sleep_ms(16);
        }
    };
}
