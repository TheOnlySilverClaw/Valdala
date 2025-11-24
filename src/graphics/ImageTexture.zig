const std = @import("std");
const fs = std.fs;
const webgpu = @import("webgpu");
const Allocator = std.mem.Allocator;
const Device = webgpu.device.Device;
const Queue = webgpu.queue.Queue;

pub const Options = struct {
    label: webgpu.StringView = .empty,
    dimension: webgpu.texture.TextureDimension = .@"2d",
    format: webgpu.texture.TextureFormat,
    view_formats: []const webgpu.texture.TextureFormat = &.{},
    usage: webgpu.texture.TextureUsage = .{
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

handle: *webgpu.texture.Texture,
queue: *webgpu.queue.Queue,

pub fn create(device: *Device, width: u32, height: u32, options: Options) Self {

    const descriptor = webgpu.texture.TextureDescriptor {
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

pub fn fromImage(device: *Device, image: @import("zigimg").Image) !Self {

    const texture = create(device, image.width, image.height, .{});
    try texture.write(image.pixels.asBytes());
}

pub fn destroy(self: Self) void {

    self.queue.release();
    self.handle.destroy();
    self.handle.release();
}

pub fn write(self: Self, pixels: []const u8) void {

    const destination = webgpu.texel.TexelCopyTextureInfo {
        .aspect = .all,
        .mip_level = 0,
        .origin = .{
            .x = 0,
            .y = 0,
            .z = 0
        },
        .texture = self.handle
    };

    const layout = webgpu.texel.TexelCopyBufferLayout {
        .offset = 0,
        // TODO map from texture format
        .bytes_per_row = self.handle.getWidth() * 4,
        .rows_per_image = self.handle.getHeight()
    };

    const extent = webgpu.Extent3D {
        .width = self.handle.getWidth(),
        .height = self.handle.getHeight(),
        .depth_or_array_layers = 1
    };
    
    self.queue.writeTexture(&destination, pixels.ptr, pixels.len, &layout, &extent);
}

pub fn writeRectangle(self: Self, pixels: []const u8, x: u32, y: u32, width: u32, height: u32) !void {

    const destination = webgpu.texel.TexelCopyTextureInfo {
        .aspect = .all,
        .mip_level = 0,
        .origin = .{
            .x = x,
            .y = y,
            .z = 0
        },
        .texture = self.handle
    };

    const layout = webgpu.texel.TexelCopyBufferLayout {
        .offset = 0,
        // TODO map from texture format
        .bytes_per_row = width,
        .rows_per_image = height
    };

    const extent = webgpu.Extent3D {
        .width = width,
        .height = height,
        .depth_or_array_layers = 1
    };
    
    self.queue.writeTexture(&destination, pixels.ptr, pixels.len, &layout, &extent);
}

pub fn createView(self: Self, options: ViewOptions) *webgpu.texture_view.TextureView {

    const descriptor = webgpu.texture_view.TextureViewDescriptor {
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

pub fn getFormat(self: Self) webgpu.texture.TextureFormat {
    return self.handle.getFormat();
}

pub fn getUsage(self: Self) webgpu.texture.TextureUsage {
    return self.handle.getUsage();
}

pub fn getMipLevels(self: Self) u32 {
    return self.handle.getMipLevelCount();
}

pub fn getSamples(self: Self) u32 {
    return self.handle.getSampleCount();
}
