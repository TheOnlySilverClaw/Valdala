const glfw = @import("glfw");
const webgpu = @import("webgpu");

const ChainedStruct = webgpu.ChainedStruct;
const SurfaceDescriptor = webgpu.SurfaceDescriptor;

const SurfaceError = error {
    PlatformUnsupported
};

pub const SurfaceDescriptorFromMetalLayer = extern struct {
    chain: ChainedStruct,
    layer: *anyopaque,
};

pub const SurfaceDescriptorFromWaylandSurface = extern struct {
    chain: ChainedStruct,
    display: glfw.native.WaylandDisplay,
    surface: glfw.native.WaylandWindow,
};

pub const SurfaceDescriptorFromWindowsHWND = extern struct {
    chain: ChainedStruct,
    hinstance: *anyopaque,
    hwnd: *anyopaque,
};

pub const SurfaceDescriptorFromXlibWindow = extern struct {
    chain: ChainedStruct,
    display: glfw.native.X11Display,
    window: glfw.native.X11Window,
};

pub fn createSurface(window: glfw.Window, instance: webgpu.Instance) SurfaceError!webgpu.Surface {
    
    const descriptor = try createDescriptor(window);
    return instance.createSurface(&descriptor);
}

fn createDescriptor(window: glfw.Window) SurfaceError!SurfaceDescriptor {

    return switch (glfw.getPlatform()) {
        .x11 => createX11SurfaceDescriptor(window),
        .wayland => createWaylandDescriptor(window),
        else => return SurfaceError.PlatformUnsupported
    };
}


fn createX11SurfaceDescriptor(glfwWindow: glfw.Window) SurfaceDescriptor {

    const x11Display = glfw.native.getX11Display();
    const x11Window = glfw.native.getX11Window(glfwWindow);
    
    const x11SurfaceDescriptor = SurfaceDescriptorFromXlibWindow {
        .chain = .{
            .type = .surface_descriptor_from_xlib_window
        },
        .display = x11Display,
        .window =  x11Window
    };

    const surfaceDescriptor = SurfaceDescriptor {
        .next = &x11SurfaceDescriptor.chain
    };

    return surfaceDescriptor;
}

fn createWaylandDescriptor(glfwWindow: glfw.Window) SurfaceDescriptor {

    const waylandDisplay = glfw.native.getWaylandDisplay();
    const waylandWindow = glfw.native.getWaylandWindow(glfwWindow);
    const waylandDescriptor = SurfaceDescriptorFromWaylandSurface {
        .chain = .{
            .type = .surface_descriptor_from_wayland_surface
        },
        .display = waylandDisplay,
        .surface = waylandWindow
    };

    const surfaceDescriptor = SurfaceDescriptor {
        .next = &waylandDescriptor.chain
    };

    return surfaceDescriptor;
}