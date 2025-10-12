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


handle: *webgpu.surface.Surface,
capabilities: webgpu.surface.SurfaceCapabilities,
depth_texture: ?*webgpu.texture.Texture,
device: *webgpu.device.Device,
queue: *webgpu.queue.Queue,
width: u32,
height: u32,
aspect: f32,

pub fn create(self: *Self, window: *glfw.window.Window, instance: *webgpu.instance.Instance) !void {
    
    self.handle = try glfw_webgpu.createSurface(window, instance);

    const adapter_options = webgpu.instance.RequestAdapterOptions {
        .compatible_surface = self.handle,
        .power_preference = .high_performance,
        .feature_level = .core
    };

    const adapter = try instance.awaitAdapter(&adapter_options);
    
    var info: webgpu.adapter.AdapterInfo = undefined;
    adapter.getInfo(&info);

    const status = self.handle.getCapabilities(adapter, &self.capabilities);
    if(status == .@"error") return Error.CapabilitiesUnavailable;

    self.device = try adapter.awaitDevice(null);
    adapter.release();

    self.queue = self.device.getQueue();

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
    self.aspect = @as(f32, @floatFromInt(self.width)) / @as(f32, @floatFromInt(self.height));
}

pub fn configure(self: *Self) void {
    
    const configuration = webgpu.surface.SurfaceConfiguration {
        .alpha_mode = self.getAlphaMode(),
        .format = self.getColorTextureFormat(),
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

    const descriptor = webgpu.texture.TextureDescriptor {
        .label = webgpu.StringView.sliced("depth"),
        .dimension = .@"2d",
        .format = self.getDepthTextureFormat(),
        .size = .{
            .width = self.width,
            .height = self.height
        },
        .usage = .{ .render_attachment = true },
        .mip_level_count = 1,
        .sample_count = 1,
        .view_format_count = 1,
        .view_formats = &.{ self.getDepthTextureFormat() }
    };

    self.depth_texture = self.device.createTexture(&descriptor);
}

pub fn getDepthTextureFormat(self: Self) webgpu.texture.TextureFormat {
    _ = self;
    return .depth24_plus;
}

pub fn getColorTexture(self: Self) Error!*webgpu.texture.Texture {
    
    var surface_texture : webgpu.surface.SurfaceTexture = undefined;
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

pub fn getColorTextureFormat(self: Self) webgpu.texture.TextureFormat {
    return self.capabilities.formats[0];
}

/// should always be set after surface is configured
pub fn getDepthTexture(self: Self) ?*webgpu.texture.Texture {
    return self.depth_texture;
}

pub fn getAlphaMode(self: Self) webgpu.surface.CompositeAlphaMode {
    return self.capabilities.alpha_modes[0];
}

pub fn getQueue(self: Self) *webgpu.queue.Queue {
    return self.queue;
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