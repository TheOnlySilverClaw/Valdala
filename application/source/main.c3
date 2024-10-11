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

    mem::@scoped(&allocator) {
        
        glfw::initialize()!;
        glfw::windowHint(glfw::window::hint::CLIENT_API, glfw::window::hint::NO_API);
    
        Window window;
        window.new(1000, 800, "Valdala")!;
    
        Camera camera;
    
        Renderer renderer;
        renderer.new(&window.surface, &camera)!;
        
        window.setup_input(&camera);
    
        while(window.keep_open()) {
            glfw::pollEvents();
            renderer.render()!;
            thread::sleep_ms(16);
        }
    
        renderer.destroy();
        window.destroy();
    
        glfw::terminate();
    };

    allocator.print_report();
}
