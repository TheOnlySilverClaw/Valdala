module graphics;

import glfw;
import webgpu;


struct Window {
    glfw::window::Window handle;
    Surface* surface;
    uint width;
    uint height;
}

fn Window*! createWindow(int width, int height, String title,
    std::core::mem::allocator::Allocator allocator = allocator::heap()) {

    glfw::window::Window handle = glfw::window::createWindow(width, height, title.zstr_tcopy());

    Window* window = allocator::alloc(allocator, Window);
    window.handle = handle;
    window.width = width;
    window.height = height;
    handle.setUserPointer(window);

    handle.setSizeCallback(fn(glfw::window::Window handle, int width, int height) {
        Window* window = handle.getUserPointer();
        window.resize(width, height);
    });

    webgpu::Instance instance = webgpu::createInstance();
    Surface* surface = createSurface(instance, window)!;
    instance.release();

    window.surface = surface;

    return window;
}

import std::io;

fn void Window.show(&self) {

    while(self.handle.shouldClose() != 1) {
        glfw::pollEvents();
        self.render();
    }
}

fn void Window.resize(&self, int width, int height) {

    self.width = width;
    self.height = height;

    self.surface.resize(width, height);
}

fn void Window.destroy(&self) {

    self.surface.destroy();
    self.handle.destroy();
}

fn void Window.render(&self) {
    self.surface.render();
}
