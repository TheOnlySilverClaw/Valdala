const webgpu = @import("webgpu");
const glfw = @import("glfw");
const glfw_webgpu = @import("glfw-webgpu.zig");

pub const SurfaceError = error {
    DeviceLost,
    TextureLost,
    TextureOutdated,
    Memory,
    Timeout
};

pub const Surface = struct {

    handle: webgpu.Surface,
    capabilities: webgpu.SurfaceCapabilities,
    alpha_mode: webgpu.AlphaMode,
    color_texture_format: webgpu.TextureFormat,
    device: webgpu.Device,
    queue: webgpu.Queue,
    width: u32,
    height: u32,

    pub fn create(window: glfw.window.Window,
        instance: webgpu.Instance) !Surface {
        
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

        const surface = Surface {
            .handle = handle,
            .capabilities = capabilities,
            .alpha_mode = capabilities.alpha_modes[0],
            .color_texture_format = capabilities.formats[0],
            .device = device,
            .queue = queue,
            .width = 0,
            .height = 0
        };
        return surface;
    }

    pub fn resize(self: *Surface, new_width: u32, new_height: u32) void {
        
        self.width = new_width;
        self.height = new_height;
        
        self.configure();
    }

    pub fn configure(self: Surface) void {
        
        const configuration = webgpu.SurfaceConfiguration {
            .alpha_mode = self.alpha_mode,
            .format = self.color_texture_format,
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

    pub fn getQueue(self: Surface) webgpu.queue.Queue {
        return self.queue;
    }

    pub fn getColorTexture(self: Surface) SurfaceError!webgpu.Texture {
        
        var surface_texture : webgpu.SurfaceTexture = undefined;
        self.handle.getCurrentTexture(&surface_texture);
        
        return switch (surface_texture.status) {
            .success => surface_texture.texture,
            .timeout => SurfaceError.Timeout,
            .device_lost => SurfaceError.DeviceLost,
            .outdated => SurfaceError.TextureOutdated,
            .lost => SurfaceError.TextureLost,
            .memory => SurfaceError.Memory
        };
    }

    pub fn present(self: Surface) void {
        self.handle.present();
    }
};