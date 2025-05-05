const std = @import("std");
const webgpu = @import("webgpu");
const glfw = @import("glfw");
const glfw_webgpu = @import("glfw-webgpu");

const assert = std.debug.assert;

pub const Error = error {
    CapabilitiesUnavailable,
    DeviceLost,
    TextureLost,
    TextureOutdated,
    Memory,
    Timeout,
    Other
};

const Self = @This();


handle: *webgpu.Surface,
capabilities: webgpu.SurfaceCapabilities,
alphaMode: webgpu.CompositeAlphaMode,
color_texture_format: webgpu.TextureFormat,
depth_texture_format: webgpu.TextureFormat,
depth_texture: ?*webgpu.Texture,
device: *webgpu.Device,
queue: *webgpu.Queue,
width: u32,
height: u32,


pub fn create(self: *Self, window: *glfw.Window, instance: *webgpu.Instance) !void {
    
    self.handle = try glfw_webgpu.createSurface(window, instance);

    const adapter_options = webgpu.RequestAdapterOptions {
        .compatible_surface = self.handle,
        .power_preference = .high_performance,
        .feature_level = .core
    };

    const adapter = try instance.awaitAdapter(&adapter_options);
    
    var info: webgpu.AdapterInfo = undefined;
    adapter.getInfo(&info);

    const status = self.handle.getCapabilities(adapter, &self.capabilities);
    if(status == .@"error") return Error.CapabilitiesUnavailable;

    self.device = try adapter.awaitDevice(null);
    adapter.release();

    self.queue = self.device.getQueue();

    self.alphaMode = self.capabilities.alpha_modes[0];
    self.color_texture_format= self.capabilities.formats[0];
    self.depth_texture_format = .depth24_plus;
    self.depth_texture = null;
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

fn createDepthTexture(self: *Self) void {

    const descriptor = webgpu.TextureDescriptor {
        .label = webgpu.StringView.sized("depth"),
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
        .success_optimal => surface_texture.texture,
        // TODO handle suboptimal?
        .success_suboptimal => surface_texture.texture,
        .timeout => Error.Timeout,
        .device_lost => Error.DeviceLost,
        .outdated => Error.TextureOutdated,
        .lost => Error.TextureLost,
        .out_of_memory => Error.Memory,
        .@"error" => Error.Other
    };
}

/// should always be set after surface is configured
pub fn getDepthTexture(self: Self) ?*webgpu.Texture {
    return self.depth_texture;
}


pub fn present(self: Self) void {
     // TODO handle status
     _ = self.handle.present();
}

pub fn destroy(self: Self) void {
    
    self.queue.release();

    if(self.depth_texture) |texture| {
        texture.destroy();
        texture.release();
    }
}