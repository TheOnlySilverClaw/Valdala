const std = @import("std");
const webgpu = @import("webgpu");
const glfw = @import("glfw");
const glfw_webgpu = @import("glfw-webgpu.zig");

const assert = std.debug.assert;

pub const Error = error {
    DeviceLost,
    TextureLost,
    TextureOutdated,
    Memory,
    Timeout
};

const Self = @This();


handle: *webgpu.Surface,
capabilities: webgpu.SurfaceCapabilities,
alphaMode: webgpu.AlphaMode,
colorTextureFormat: webgpu.TextureFormat,
depth_texture_format: webgpu.TextureFormat,
depth_texture: ?*webgpu.Texture,
device: *webgpu.Device,
queue: *webgpu.Queue,
width: u32,
height: u32,

pub fn create(window: glfw.Window, instance: *webgpu.Instance) !Self {
    
    const handle = try glfw_webgpu.createSurface(window, instance);
    
    const adapter = try instance.requestAdapterSync(&.{
        .compatible_surface = handle,
        .power_preference = .high_performance
    });

    const device = try adapter.requestDeviceSync(null);

    var capabilities: webgpu.SurfaceCapabilities = undefined;
    handle.getCapabilities(adapter, &capabilities);
    adapter.release();

    const queue = device.getQueue();

    return.{
        .handle = handle,
        .capabilities = capabilities,
        .alphaMode = capabilities.alpha_modes[0],
        .colorTextureFormat = capabilities.formats[0],
        .depth_texture_format = .depth24_plus,
        .depth_texture = null,
        .device = device,
        .queue = queue,
        .width = 0,
        .height = 0
    };
}

pub fn resize(self: *Self, width: u32, height: u32) void {
    
    self.width = width;
    self.height = height;
    
    self.configure();
    
    if(self.depth_texture) |texture| {
        texture.destroy();
        texture.release();
    }
    
    self.createDepthTexture();
}

pub fn configure(self: *Self) void {
    
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

fn createDepthTexture(self: *Self) void {

    const descriptor = webgpu.TextureDescriptor {
        .label = "depth",
        .dimension = .@"2d",
        .format = self.depth_texture_format,
        .size = .{
            .width = self.width,
            .height = self.height
        },
        .usage = .{ .render_attachment = true },
        .mip_level_count = 1,
        .sample_count = 1,
        .view_format_count = 1,
        .view_formats = &.{ self.depth_texture_format }
    };

    self.depth_texture = self.device.createTexture(&descriptor);
}

pub fn getQueue(self: Self) *webgpu.Queue {
    return self.queue;
}

pub fn getColorTexture(self: Self) Error!*webgpu.Texture {
    
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

/// should always be set after surface is configured
pub fn getDepthTexture(self: Self) ?*webgpu.Texture {
    return self.depth_texture;
}


pub fn present(self: Self) void {
    self.handle.present();
}

pub fn destroy(self: Self) void {
    
    self.queue.release();

    if(self.depth_texture) |texture| {
        texture.destroy();
        texture.release();
    }
}