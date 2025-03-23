const glfw = @import("glfw");
const webgpu = @import("webgpu");

const target_os = @import("builtin").target.os.tag;

const ChainedStruct = webgpu.ChainedStruct;
const SurfaceDescriptor = webgpu.SurfaceDescriptor;

const SurfaceError = error {
    PlatformUnsupported,
    BackendUnavailable
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


pub fn createSurface(window: *glfw.Window, instance: *webgpu.Instance) SurfaceError!*webgpu.Surface {

    switch (target_os) {
        .linux => {
            return switch (glfw.getPlatform()) {
                .x11 => createX11Surface(window, instance),
                .wayland => createWaylandSurface(window, instance),
                else => return SurfaceError.PlatformUnsupported
            };
        },
        .macos => return createMetalSurface(window, instance),
        .windows => return createWindowsSurface(window, instance),
        else => return SurfaceError.PlatformUnsupported,
    }
}


fn createX11Surface(glfw_window: *glfw.Window, instance: *webgpu.Instance) SurfaceError!*webgpu.Surface {

    const x11_display = glfw.native.getX11Display() orelse return SurfaceError.BackendUnavailable;
    const x11_window = glfw.native.getX11Window(glfw_window);

    const x11_surface_descriptor = SurfaceDescriptorFromXlibWindow {
        .chain = .{
            .type = .surface_source_xlib_window
        },
        .display = x11_display,
        .window =  x11_window
    };

    const surface_descriptor = SurfaceDescriptor {
        .next = &x11_surface_descriptor.chain
    };

    return instance.createSurface(&surface_descriptor);
}

fn createWaylandSurface(glfw_window: *glfw.Window, instance: *webgpu.Instance) SurfaceError!*webgpu.Surface {

    const wayland_display = glfw.native.getWaylandDisplay() orelse return SurfaceError.BackendUnavailable;
    const wayland_window = glfw.native.getWaylandWindow(glfw_window) orelse return SurfaceError.BackendUnavailable;
    const wayland_descriptor = SurfaceDescriptorFromWaylandSurface {
        .chain = .{
            .type = .surface_source_wayland_surface
        },
        .display = wayland_display,
        .surface = wayland_window
    };

    const surface_descriptor = SurfaceDescriptor {
        .next = &wayland_descriptor.chain
    };

    return instance.createSurface(&surface_descriptor);
}

extern fn setupMetalLayer(ns_window: *anyopaque) ?*anyopaque;

fn createMetalSurface(glfw_window: *glfw.Window, instance: *webgpu.Instance) SurfaceError!*webgpu.Surface {

    const ns_window = glfw_window.getCocoaWindow();
    const metal_layer = setupMetalLayer(ns_window);

    if (metal_layer == null) return SurfaceError.BackendUnavailable;

    const metal_descriptor = SurfaceDescriptorFromMetalLayer {
        .chain = .{ .next = null, .type = .surface_source_metal_layer },
        .layer = metal_layer.?
    };

    const surface_descriptor = SurfaceDescriptor {
        .next = &metal_descriptor.chain
    };

    return instance.createSurface(&surface_descriptor);

}


// windows api
const LPCSTR = ?[*:0]const u8;
const HMODULE = *opaque {};
extern fn GetModuleHandleA(lpModuleName: LPCSTR) ?HMODULE;

fn createWindowsSurface(glfw_window: *glfw.Window, instance: *webgpu.Instance) SurfaceError!*webgpu.Surface {

    const hwnd = glfw_window.getWin32Window() orelse return SurfaceError.BackendUnavailable;
    const hinstance = GetModuleHandleA(null) orelse return SurfaceError.BackendUnavailable;

    const hwnd_descriptor = SurfaceDescriptorFromWindowsHWND {
        .hwnd = hwnd,
        .hinstance = hinstance,
        .chain = .{ .next = null, .type = .surface_source_windows_hwnd }
    };

    const surface_descriptor = SurfaceDescriptor {
        .next = &hwnd_descriptor.chain
    };

    return instance.createSurface(&surface_descriptor);

}
