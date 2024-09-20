module graphics;

import glfw;
import webgpu;

def GlfwHandle = glfw::window::Window;
def WebGPUInstance = webgpu::Instance;

struct Window {
    GlfwHandle handle;
    Surface surface;
    int width;
    int height;
}

fn Window! createWindow(int width, int height, String title) {

    GlfwHandle handle = glfw::window::createWindow(width, height, title.zstr_tcopy());

    Window window;
    window.handle = handle;
    handle.setUserPointer(&window);

    handle.setSizeCallback(fn(GlfwHandle handle, int width, int height) {
        Window* window = handle.getUserPointer();
        window.resize(width, height);
    });

    WebGPUInstance instance = webgpu::createInstance();
    Surface surface = createSurface(instance, handle)!;
    instance.release();

    window.surface = surface;

    window.width = width;
    window.height = height;

    return window;
}

import std::io;

fn void Window.show(self) {

    while(self.handle.shouldClose() != 1) {
        glfw::pollEvents();
    }
}

fn void Window.resize(&self, int width, int height) {

    self.width = width;
    self.height = height;
}

fn void Window.destroy(&self) {

    self.surface.destroy();
    self.handle.destroy();
}
