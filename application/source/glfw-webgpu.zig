const glfw = @import("glfw");
const webgpu = @import("webgpu");
const surface = webgpu.surface;

const SurfaceError = error {
    platform_unsupported
};

pub fn createSurface(window: glfw.window.Window, instance: webgpu.instance.Instance) SurfaceError!surface.Surface {
    
    const descriptor = try createDescriptor(window);
    return instance.createSurface(&descriptor);
}

fn createDescriptor(window: glfw.window.Window) SurfaceError!surface.SurfaceDescriptor {

    return switch (glfw.getPlatform()) {
        .x11 => createX11SurfaceDescriptor(window),
        else => return SurfaceError.platform_unsupported
    };
}


fn createX11SurfaceDescriptor(glfwWindow: glfw.window.Window) surface.SurfaceDescriptor {

    const x11Display = glfw.native.getX11Display();
    const x11Window = glfw.native.getX11Window(glfwWindow);
    
    const x11SurfaceDescriptor = surface.SurfaceDescriptorFromXlibWindow {
        .chain = .{
            .type = .surface_descriptor_from_xlib_window
        },
        .display = x11Display,
        .window =  x11Window
    };

    const surfaceDescriptor = surface.SurfaceDescriptor {
        .next = &x11SurfaceDescriptor.chain
    };

    return surfaceDescriptor;
}