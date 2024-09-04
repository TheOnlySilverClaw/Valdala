import glfw;
import webgpu;

def GlfwWindow = glfw::Window;

extern fn X11Display glfwGetX11Display();

extern fn X11Window glfwGetX11Window(GlfwWindow window);

fn Surface createSurface(Instance instance, GlfwWindow window) {

        X11Display x11Display = glfwGetX11Display();
        X11Window x11Window = glfwGetX11Window(window);

        SurfaceDescriptorFromXlibWindow fromXlibWindow;
        fromXlibWindow.chain.next = null;
        fromXlibWindow.chain.sType = SType.SURFACE_DESCRIPTOR_FROM_XLIB_WINDOW;
        fromXlibWindow.display = x11Display;
        fromXlibWindow.window = x11Window;

        SurfaceDescriptor surfaceDescriptor;
        surfaceDescriptor.nextInChain = &fromXlibWindow.chain;
        surfaceDescriptor.label = null;

        return instance.createSurface(&surfaceDescriptor);
}