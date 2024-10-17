const shared = @import("shared.zig");
const texture = @import("texture.zig");
const adapter = @import("adapter.zig");
const device = @import("device.zig");

pub const Surface = *opaque {

    pub fn configure(surface: Surface, configuration: *const SurfaceConfiguration) void {
        wgpuSurfaceConfigure(surface, configuration);
    }

    pub fn getCapabilitirs(surface: Surface,
        surface_adapter: adapter.Adapter, capalities: *SurfaceCapabilities) void {
        wgpuSurfaceGetCapabilities(surface, surface_adapter, capalities);
    }

    pub fn getCurrentTexture(surface: Surface, surface_texture: *SurfaceTexture) void {
        wgpuSurfaceGetCurrentTexture(surface, surface_texture);
    }

    pub fn present(surface: Surface) void {
        wgpuSurfacePresent(surface);
    }

    pub fn unconfigure(surface: Surface) void {
        wgpuSurfaceUnconfigure(surface);
    }

    pub fn setLabel(surface: Surface, label: [*:0] const u8) void {
        wgpuSurfaceSetLabel(surface, label);
    }

    pub fn reference(surface: Surface) void {
        wgpuSurfaceReference(surface);
    }

    pub fn release(surface: Surface) void {
        wgpuSurfaceRelease(surface);
    }
};


pub const PresentMode = enum(u32) {
    immediate,
    mailbox,
    fifo,
};

const SurfaceCapabilities = extern struct {
    next: ?*const shared.ChainedStruct = null,
    usages: texture.TextureUsageFlags,
    format_count: usize,
    formats: ?[*]const texture.TextureFormat,
    present_mode_count: usize,
    present_modes: ?[*]const PresentMode,
    alpha_mode_count: usize,
    alpha_modes: ?[*]const texture.AlphaMode,
};

const SurfaceConfiguration = extern struct {
    next: ?*const shared.ChainedStruct = null,
    device: device.Device,
    format: texture.TextureFormat,
    usage: texture.TextureUsageFlags,
    view_format_count: usize,
    view_formats: ?[*]const texture.TextureFormat,
    alpha_mode: texture.AlphaMode,
    width: u32,
    height: u32,
    present_mode: PresentMode
};


pub const SurfaceDescriptor = extern struct {
    next: ?*const shared.shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    usage: texture.TextureUsage,
    format: texture.TextureFormat,
    width: u32,
    height: u32,
    present_mode: PresentMode,
};

pub const SurfaceDescriptorFromMetalLayer = extern struct {
    chain: shared.ChainedStruct,
    layer: *anyopaque,
};

pub const SurfaceDescriptorFromWaylandSurface = extern struct {
    chain: shared.ChainedStruct,
    display: *anyopaque,
    surface: *anyopaque,
};

pub const SurfaceDescriptorFromWindowsHWND = extern struct {
    chain: shared.ChainedStruct,
    hinstance: *anyopaque,
    hwnd: *anyopaque,
};

pub const SurfaceDescriptorFromXlibWindow = extern struct {
    chain: shared.ChainedStruct,
    display: *anyopaque,
    window: u32,
};

pub const SurfaceDescriptorFromCanvasHTMLSelector = extern struct {
    chain: shared.ChainedStruct,
    selector: [*:0]const u8,
};

pub const SurfaceGetCurrentTextureStatus = enum {
    success,
    timeout,
    outdated,
    lost,
    memory,
    device_lost
};

pub const SurfaceTexture = extern struct {
    texture: texture.Texture,
    suboptimal: bool,
    status: SurfaceGetCurrentTextureStatus  
};


extern fn wgpuSurfaceConfigure(surface: Surface, configuration: *const SurfaceConfiguration) void;

extern fn wgpuSurfaceGetCapabilities(surface: Surface, surface_adapter: adapter.Adapter, capabilities: *SurfaceCapabilities) void;

extern fn wgpuSurfaceGetCurrentTexture(surface: Surface, surface_texture: *SurfaceTexture) void;

extern fn wgpuSurfacePresent(surface: Surface) void;

extern fn wgpuSurfaceSetLabel(surface: Surface, label: [*:0]const u8) void;

extern fn wgpuSurfaceUnconfigure(surface: Surface) void;

extern fn wgpuSurfaceReference(surface: Surface) void;

extern fn wgpuSurfaceRelease(surface: Surface) void;