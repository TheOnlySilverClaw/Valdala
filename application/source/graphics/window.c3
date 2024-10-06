module graphics;

import std::thread;

import glfw::window;
import glfw::input;
import glfw::keyboard;

import webgpu;

struct Window {
    window::Window handle;
    Surface surface;
    Camera* camera;
}

fn void! Window.new(&self, int width, int height, ZString title) {

    window::Window handle = window::createWindow(width, height, title);
    self.handle = handle;
    
    handle.setUserPointer(self);
    
    handle.setSizeCallback(fn(glfw::window::Window handle, int width, int height) {
        Window* window = handle.getUserPointer();
        window.resize(width, height);
    });
    
    webgpu::Instance instance = webgpu::createInstance();
    self.surface.new(self, width, height, instance)!;
    instance.release();
}

fn bool Window.keep_open(&self) {
    return !self.handle.shouldClose();
}

fn void Window.resize(&self, int width, int height) {
    self.surface.resize(width, height);
}

fn void Window.setup_input(&self, Camera* camera) {

    self.camera = camera;

    self.handle.setKeyCallback(fn void(
        window::Window handle,
        keyboard::Key key,
        keyboard::Scancode scancode,
        input::Action action,
        input::Modifiers modifiers) {

        Window* window = handle.getUserPointer();
        
        if(action == PRESS || action == REPEAT) {
            switch(key) {
                case keyboard::key::A: window.camera.position.x -= 0.1;
                case keyboard::key::D: window.camera.position.x += 0.1;
                case keyboard::key::W: window.camera.position.y += 0.1;
                case keyboard::key::S: window.camera.position.y -= 0.1;
                default: ;
            }
        }
    });
}

fn void Window.destroy(&self) {
    self.surface.destroy();
    self.handle.destroy();
}
