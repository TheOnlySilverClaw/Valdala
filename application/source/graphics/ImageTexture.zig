const std = @import("std");
const fs = std.fs;
const webgpu = @import("webgpu");
const img = @import("zigimg");
const Allocator = std.mem.Allocator;
const Extent3D = webgpu.Extent3D;
const Device = webgpu.Device;
const Queue = webgpu.Queue;


pub const Error = error {
    DimensionMismatch
};

const Self = @This();


width: u32,
height: u32,
format: webgpu.TextureFormat,
mipLevels: u32 = 1,
samples: u32 = 1,
label: ?[*:0]const u8 = null,

handle: webgpu.Texture = undefined,

pub fn create(self: *Self, device: Device) void {

    const descriptor = webgpu.TextureDescriptor {
        .label = self.label,
        .dimension = .@"2d",
        .format = self.format,
        .mip_level_count = self.mipLevels,
        .size = .{
            .width = self.width,
            .height = self.height,
            .depth = 1
        },
        .usage = .{
            .texture_binding = true,
            .copy_dst = true
        },
        .view_format_count = 0,
        .view_formats = null,
        .sample_count = self.samples
    };

    self.handle =  device.createTexture(&descriptor);
}

pub fn destroy(self: Self) void {

    self.handle.destroy();
    self.handle.release();
}

pub fn loadImagePixels(self: Self, pixels: []const u8, queue: webgpu.Queue) !void {

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

    const layout = webgpu.TextureDataLayout {
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
    
    queue.writeTexture(&destination, pixels.ptr, pixels.len, &layout, &extent);
}

pub fn loadImagePixelsRectangle(self: Self, pixels: []const u8, queue: webgpu.Queue, x: u32, y: u32, width: u32, height: u32) !void {

    const destination = webgpu.ImageCopyTexture {
        .aspect = .all,
        .mip_level = 0,
        .origin = .{
            .x = x,
            .y = y,
            .z = 0
        },
        .texture = self.handle
    };

    const layout = webgpu.TextureDataLayout {
        .offset = 0,
        // TODO map from texture format
        .bytes_per_row = width,
        .rows_per_image = height
    };

    const extent = Extent3D {
        .width = width,
        .height = height,
        .depth = 1
    };
    
    queue.writeTexture(&destination, pixels.ptr, pixels.len, &layout, &extent);
}

pub fn loadImageFile(self: Self, allocator: Allocator, queue: Queue, path: []const u8) !void {

    var file = try fs.cwd().openFile(path, .{});
    defer file.close();

    var image = try img.ImageUnmanaged.fromFile(allocator, file);
    defer image.deinit(allocator);

    if(image.width != @as(usize, self.width)) return Error.ImageDimensionMismatch;
    if(image.height != @as(usize, self.height)) return Error.ImageDimensionMismatch;

    // TODO map from surface texture format?
    try image.convert(allocator, .bgra32);

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

    const layout = webgpu.TextureDataLayout {
        .offset = 0,
        .bytes_per_row = @intCast(image.rowByteSize()),
        .rows_per_image = self.height
    };

    const extent = Extent3D {
        .width = self.width,
        .height = self.height,
        .depth = 1
    };
    
    const pixels = image.pixels.asConstBytes();
    queue.writeTexture(&destination, pixels.ptr, pixels.len, &layout, &extent);
}

pub fn createView(self: Self) webgpu.TextureView {

    const descriptor = webgpu.TextureViewDescriptor {
        .array_layer_count = 1,
        .aspect = .all,
        .base_array_layer = 0,
        .base_mip_level = 0,
        .dimension = .@"2d",
        .format = self.format,
        .label = self.label,
        .mip_level_count = self.mipLevels
    };

    return self.handle.createView(&descriptor);
}
