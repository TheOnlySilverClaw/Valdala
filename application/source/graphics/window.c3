module graphics;

import std::thread;

import glfw::window;
import webgpu;


struct Window {
    window::Window handle;
    Surface surface;
    uint width;
    uint height;
}

fn void! Window.new(&self, int width, int height, String title, Allocator allocator) {

    self.width = width;
    self.height = height;

    window::Window handle = window::createWindow(width, height, title.zstr_tcopy());
    self.handle = handle;
    
    handle.setUserPointer(self);
    
    handle.setSizeCallback(fn(glfw::window::Window handle, int width, int height) {
        Window* window = handle.getUserPointer();
        window.resize(width, height);
    });
    
    webgpu::Instance instance = webgpu::createInstance();
    self.surface.new(instance, self, allocator)!;
    instance.release();
}

import std::io;

fn void Window.show(&self) {

    while(self.handle.shouldClose() != 1) {
        glfw::pollEvents();
        self.render();
        thread::sleep_ms(16);
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
