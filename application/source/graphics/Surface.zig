const webgpu = @import("webgpu");
const glfw = @import("glfw");
const glfw_webgpu = @import("glfw-webgpu.zig");

pub const Error = error {
    DeviceLost,
    TextureLost,
    TextureOutdated,
    Memory,
    Timeout
};

const Self = @This();


handle: webgpu.Surface,
capabilities: webgpu.SurfaceCapabilities,
alphaMode: webgpu.AlphaMode,
colorTextureFormat: webgpu.TextureFormat,
device: webgpu.Device,
queue: webgpu.Queue,
width: u32,
height: u32,

pub fn create(window: glfw.Window, instance: webgpu.Instance) !Self {
    
    const handle = try glfw_webgpu.createSurface(window, instance);
    
    const adapter = try instance.requestAdapter(&.{
        .compatible_surface = handle,
        .power_preference = .high_performance
    });

    const device = try adapter.requestDevice(null);

    var capabilities: webgpu.SurfaceCapabilities = undefined;
    handle.getCapabilities(adapter, &capabilities);
    adapter.release();

    const queue = device.getQueue();

    return.{
        .handle = handle,
        .capabilities = capabilities,
        .alphaMode = capabilities.alpha_modes[0],
        .colorTextureFormat = capabilities.formats[0],
        .device = device,
        .queue = queue,
        .width = 0,
        .height = 0
    };
}

pub fn resize(self: *Self, new_width: u32, new_height: u32) void {
    
    self.width = new_width;
    self.height = new_height;
    
    self.configure();
}

pub fn configure(self: Self) void {
    
    const configuration = webgpu.SurfaceConfiguration {
        .alpha_mode = self.alphaMode,
        .format = self.colorTextureFormat,
        .device = self.device,
        .width = self.width,
        .height = self.height,
        .present_mode = .fifo,
        .usage = .{ .render_attachment = true },
        .view_format_count = 0,
        .view_formats = null
    };

    self.handle.configure(&configuration);
}

pub fn getQueue(self: Self) webgpu.queue.Queue {
    return self.queue;
}

pub fn getColorTexture(self: Self) Error!webgpu.Texture {
    
    var surface_texture : webgpu.SurfaceTexture = undefined;
    self.handle.getCurrentTexture(&surface_texture);
    
    return switch (surface_texture.status) {
        .success => surface_texture.texture,
        .timeout => Error.Timeout,
        .device_lost => Error.DeviceLost,
        .outdated => Error.TextureOutdated,
        .lost => Error.TextureLost,
        .memory => Error.Memory
    };
}

pub fn present(self: Self) void {
    self.handle.present();
}
