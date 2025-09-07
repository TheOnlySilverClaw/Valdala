const std = @import("std");
const fs = std.fs;
const webgpu = @import("webgpu");
const Allocator = std.mem.Allocator;
const Extent3D = webgpu.Extent3D;
const Device = webgpu.Device;
const Queue = webgpu.Queue;

pub const Options = struct {
    label: webgpu.StringView = .empty,
    dimension: webgpu.TextureDimension = .@"2d",
    format: webgpu.TextureFormat,
    view_formats: []const webgpu.TextureFormat = &.{},
    usage: webgpu.TextureUsage = .{
        .texture_binding = true,
        .copy_dst = true
    },
    mip_levels: u32 = 1,
    samples: u32 = 1
};

pub const ViewOptions = struct {
    label: webgpu.StringView = .empty,
};

const Self = @This();

handle: *webgpu.Texture,
queue: *webgpu.Queue,

pub fn create(device: *Device, width: u32, height: u32, options: Options) Self {

    const descriptor = webgpu.TextureDescriptor {
        .label = options.label,
        .dimension = .@"2d",
        .format = options.format,
        .mip_level_count = options.mip_levels,
        .size = .{
            .width = width,
            .height = height,
            .depth_or_array_layers = 1
        },
        .usage = options.usage,
        .view_format_count = options.view_formats.len,
        .view_formats = options.view_formats.ptr,
        .sample_count = options.samples
    };

    const handle =  device.createTexture(&descriptor);
    return .{
        .handle = handle,
        .queue = device.getQueue()
    };
}

pub fn destroy(self: Self) void {

    self.queue.release();
    self.handle.destroy();
    self.handle.release();
}

pub fn write(self: Self, pixels: []const u8) !void {

    const destination = webgpu.ImageCopyTexture {
        .aspect = .all,
        .mip_level = 0,
        .origin = .{
            .x = 0,
            .y = 0,
            .z = 0
        },
        .texture = self.handle
    };

    const layout = webgpu.TexelCopyTextureInfo {
        .offset = 0,
        // TODO map from texture format
        .bytes_per_row = 4,
        .rows_per_image = self.height
    };

    const extent = Extent3D {
        .width = self.width,
        .height = self.height,
        .depth = 1
    };
    
    self.queue.writeTexture(&destination, pixels.ptr, pixels.len, &layout, &extent);
}

pub fn writeRectangle(self: Self, pixels: []const u8, x: u32, y: u32, width: u32, height: u32) !void {

    const destination = webgpu.TexelCopyTextureInfo {
        .aspect = .all,
        .mip_level = 0,
        .origin = .{
            .x = x,
            .y = y,
            .z = 0
        },
        .texture = self.handle
    };

    const layout = webgpu.TexelCopyBufferLayout {
        .offset = 0,
        // TODO map from texture format
        .bytes_per_row = width,
        .rows_per_image = height
    };

    const extent = Extent3D {
        .width = width,
        .height = height,
        .depth_or_array_layers = 1
    };
    
    self.queue.writeTexture(&destination, pixels.ptr, pixels.len, &layout, &extent);
}

pub fn createView(self: Self, options: ViewOptions) *webgpu.TextureView {

    const descriptor = webgpu.TextureViewDescriptor {
        .label = options.label,
        .dimension = .@"2d",
        .format = self.getFormat(),
        .base_array_layer = 0,
        .array_layer_count = 1,
        .aspect = .all,
        .base_mip_level = 0,
        .mip_level_count = self.getMipLevels(),
        .usage = self.getUsage()
    };

    return self.handle.createView(&descriptor);
}

pub fn getWidth(self: Self) u32 {
    return self.handle.getWidth();
}

pub fn getHeight(self: Self) u32 {
    return self.handle.getHeight();
}

pub fn getDepth(self: Self) u32 {
    return self.handle.getDepthOrArrayLayers();
}

pub fn getFormat(self: Self) webgpu.TextureFormat {
    return self.handle.getFormat();
}

pub fn getUsage(self: Self) webgpu.TextureUsage {
    return self.handle.getUsage();
}

pub fn getMipLevels(self: Self) u32 {
    return self.handle.getMipLevelCount();
}

pub fn getSamples(self: Self) u32 {
    return self.handle.getSampleCount();
}
