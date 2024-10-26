const webgpu = @import("webgpu");
const glfw = @import("glfw");
const glfw_webgpu = @import("../glfw-webgpu.zig");
const binding = webgpu.surface;

pub const SurfaceError = error {
    DeviceLost,
    TextureLost,
    TextureOutdated,
    Memory,
    Timeout
};

pub const Surface = struct {

    handle: binding.Surface,
    capabilities: binding.SurfaceCapabilities,
    configuration: binding.SurfaceConfiguration,
    queue: webgpu.queue.Queue,

    pub fn create(window: glfw.window.Window,
        instance: webgpu.instance.Instance) !Surface {
        
        const handle = try glfw_webgpu.createSurface(window, instance);
        
        const adapter = try instance.requestAdapter(&.{
            .compatible_surface = handle,
            .power_preference = .high_performance
        });

        const device = try adapter.requestDevice(null);

        var capabilities: binding.SurfaceCapabilities = undefined;
        handle.getCapabilities(adapter, &capabilities);
        adapter.release();

        const queue = device.getQueue();

        const configuration = binding.SurfaceConfiguration {
            .alpha_mode = capabilities.alpha_modes[0],
            .format = capabilities.formats[0],
            .device = device,
            .width = 0,
            .height = 0,
            .present_mode = .fifo,
            .usage = .{ .render_attachment = true },
            .view_format_count = 0,
            .view_formats = null
        };

        const surface = Surface {
            .handle = handle,
            .capabilities = capabilities,
            .configuration = configuration,
            .queue = queue
        };
        return surface;
    }

    pub fn resize(self: *Surface, new_width: u32, new_height: u32) void {
        
        self.configuration.width = new_width;
        self.configuration.height = new_height;
        
        self.configure();
    }

    pub fn configure(self: *Surface) void {
        self.handle.configure(&self.configuration);
    }

    pub fn getWidth(self: Surface) u32 {
        return self.configuration.width;
    }

    pub fn getHeight(self: Surface) u32 {
        return self.configuration.height;
    }

    pub fn getDevice(self: Surface) webgpu.device.Device {
        return self.configuration.device;
    }

    pub fn getQueue(self: Surface) webgpu.queue.Queue {
        return self.queue;
    }

    pub fn getColorTextureFormat(self: Surface) webgpu.texture.TextureFormat {
        return self.configuration.format;
    }

    pub fn getColorTexture(self: Surface) SurfaceError!webgpu.texture.Texture {
        
        var surface_texture : webgpu.surface.SurfaceTexture = undefined;
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