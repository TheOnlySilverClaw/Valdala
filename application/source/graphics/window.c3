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

fn void! Window.new(&self, int width, int height, ZString title) {

    self.width = width;
    self.height = height;

    window::Window handle = window::createWindow(width, height, title);
    self.handle = handle;
    
    handle.setUserPointer(self);
    
    handle.setSizeCallback(fn(glfw::window::Window handle, int width, int height) {
        Window* window = handle.getUserPointer();
        window.resize(width, height);
    });
    
    webgpu::Instance instance = webgpu::createInstance();
    self.surface.new(self, instance)!;
    instance.release();
}

fn bool Window.keep_open(&self) {
    return !self.handle.shouldClose();
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
