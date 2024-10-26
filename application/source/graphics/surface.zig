const webgpu = @import("webgpu");
const glfw = @import("glfw");
const glfw_webgpu = @import("../glfw-webgpu.zig");
const binding = webgpu.surface;

pub const Surface = struct {

    handle: binding.Surface,
    capabilities: binding.SurfaceCapabilities,
    configuration: binding.SurfaceConfiguration,

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
            .configuration = configuration
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

    pub fn width(self: Surface) u32 {
        return self.configuration.width;
    }

    pub fn height(self: Surface) u32 {
        return self.configuration.height;
    }

    pub fn color_texture_format(self: Surface) webgpu.texture.TextureFormat {
        return self.configuration.format;
    }

    pub fn render(self: Surface) void {

        const device = self.configuration.device;
        
        var surface_texture: binding.SurfaceTexture = undefined;
        self.handle.getCurrentTexture(&surface_texture);

        const color_texture = surface_texture.texture;
        const frame = color_texture.createView(null);

        const command_encoder = device.createCommandEncoder(null);
        
        const color_attachment = webgpu.render_pass_encoder.RenderPassColorAttachment {
            .clear_value = .{ .r = 0.53, .g = 0.81, .b = 0.92, .a = 1.0 },
            .load_op = .clear,
            .store_op = .store,
            .view = frame
        };

        const descriptor = webgpu.render_pass_encoder.RenderPassDescriptor {
            .color_attachment_count = 1,
            .color_attachments = &.{color_attachment},
            .depth_stencil_attachment = null,
        };

        const render_pass_encoder = command_encoder.beginRenderPass(&descriptor);
        render_pass_encoder.end();
        render_pass_encoder.release();

        const command_buffer = command_encoder.finish(null);
        command_encoder.release();

        const queue = device.getQueue();
        queue.submit(&.{command_buffer});
        command_buffer.release();
        queue.release();
        
        self.handle.present();
        
        frame.release();
        color_texture.release();
    }
};