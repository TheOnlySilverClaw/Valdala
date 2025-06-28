const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const zigimg = @import("zigimg");
const webgpu = @import("webgpu");
const yaml = @import("yaml");

const folders = @import("folders.zig");

const Allocator = mem.Allocator;
const Image = zigimg.ImageUnmanaged;

const Self = @This();


allocator: Allocator,
device: *webgpu.Device,
root: []const u8,

pub fn init(allocator: Allocator, device: *webgpu.Device, root: []const u8) !Self {

    return .{
        .allocator = allocator,
        .device = device,
        .root= root,
    };
}

pub fn deinit(self: Self) void {
    _ = self;
}


const shader_max_bytes = 1024 * 64;

fn getName(path: []const u8) ?[]const u8 {
    
    const file_name = fs.path.basename(path);
    var split = mem.splitScalar(u8, file_name, '.');
    return split.next();
}

fn getLabel(path: []const u8) webgpu.StringView {
    
    if(getName(path)) |name| {
        return webgpu.StringView.sized(name);
    } else {
        return webgpu.StringView.empty;
    }
}

pub fn loadShader(self: Self, path: []const u8) !*webgpu.ShaderModule {

    const full_path = try fs.path.join(self.allocator, &.{ self.root, folders.shader, path });
    defer self.allocator.free(full_path);

    const file = try fs.cwd().openFile(full_path, .{});
    defer file.close();

    const source = try file.readToEndAlloc(self.allocator, shader_max_bytes);
    defer self.allocator.free(source);

    const shader_label = getLabel(path);

    const source_descriptor = webgpu.ShaderSourceWGSL {
        .chain = .{ .type = .shader_source_wgsl },
        .code = webgpu.StringView.sized(source)
    };

    const descriptor = webgpu.ShaderModuleDescriptor {
        .next = &source_descriptor.chain,
        .label = shader_label
    };

    return self.device.createShaderModule(&descriptor);
}

pub const TextureOptions = struct {
    mip_levels: u32 = 1,
    samples: u32 = 1,
    view_formaats: []webgpu.TextureFormat = &.{}
};

pub fn loadTextureImage(self: Self, path: []const u8, format: webgpu.TextureFormat, options: TextureOptions) !*webgpu.Texture {

    const full_path = try fs.path.join(self.allocator, &.{ self.root, folders.texture, path });
    defer self.allocator.free(full_path);

    var file = try fs.cwd().openFile(full_path, .{});
    defer file.close();

    var image = try Image.fromFile(self.allocator, &file);
    defer image.deinit(self.allocator);

    const texture_label = getLabel(path);

    const descriptor = webgpu.TextureDescriptor {
        .label = texture_label,
        .dimension = .@"2d",
        .format = format,
        .mip_level_count = options.mip_levels,
        .size = .{
            .width = image.width,
            .height = image.height,
            .depth_or_array_layers = 1
        },
        .usage = .{
            .texture_binding = true,
            .copy_dst = true
        },
        .view_format_count = options.view_formaats.len,
        .view_formats = options.view_formaats.ptr,
        .sample_count = options.samples
    };

    const texture = self.device.createTexture(&descriptor);
    const queue = self.device.getQueue();
    defer queue.release();

    loadImagePixels(texture, queue, image.pixels.asConstBytes(), image.pixelFormat().channelCount(), 0);
    return texture;
}

pub const TextureArrayOptions = struct {
    label: webgpu.StringView,
    mip_levels: u32 = 1,
    samples: u32 = 1,
    view_formaats: []webgpu.TextureFormat = &.{}
};

pub fn loadTextureArray(self: Self, paths: []const []const u8, width: u32, height: u32, options: TextureArrayOptions) !*webgpu.Texture {

    const descriptor = webgpu.TextureDescriptor {
        .label = options.label,
        .dimension = .@"2d",
        .format = .rgba8_unorm_srgb,
        .mip_level_count = options.mip_levels,
        .size = .{
            .width = width,
            .height = height,
            .depth_or_array_layers = @intCast(paths.len)
        },
        .usage = .{
            .texture_binding = true,
            .copy_dst = true
        },
        .view_format_count = options.view_formaats.len,
        .view_formats = options.view_formaats.ptr,
        .sample_count = options.samples
    };

    const texture = self.device.createTexture(&descriptor);
    const queue = self.device.getQueue();
    defer queue.release();

    for(paths, 0..) |path, layer| {
        const full_path = try fs.path.join(self.allocator, &.{ self.root, folders.texture, path });
        defer self.allocator.free(full_path);

        var file = try fs.cwd().openFile(full_path, .{});
        defer file.close();

        var image = try Image.fromFile(self.allocator, &file);
        try image.convert(self.allocator, .rgba32);

        defer image.deinit(self.allocator);
    
        // TODO handle differing channel counts?
        try loadImagePixelsRectangle(texture, queue, image.pixels.asConstBytes(), image.pixelFormat().channelCount(), @intCast(layer), 0, 0, @intCast(image.width), @intCast(image.height));
    }

    return texture;
}

fn loadImagePixels(texture: *webgpu.Texture, queue: *webgpu.Queue, pixels: []const u8, channels: u32, layer: u32) !void {

    try loadImagePixelsRectangle(texture, queue, pixels, channels, 0, 0, texture.getWidth(), texture.getHeight(), layer);
}

fn loadImagePixelsRectangle(texture: *webgpu.Texture, queue: *webgpu.Queue, pixels: []const u8, channels: u32, layer: u32, x: u32, y: u32, width: u32, height: u32) !void {
    
    const destination = webgpu.TexelCopyTextureInfo {
        .aspect = .all,
        .mip_level = 0,
        .origin = .{
            .x = x,
            .y = y,
            .z = layer
        },
        .texture = texture
    };

    const layout = webgpu.TexelCopyBufferLayout {
        .offset = 0,
        .bytes_per_row = width * channels,
        .rows_per_image = height
    };

    const extent = webgpu.Extent3D {
        .width = width,
        .height = height,
        .depth_or_array_layers = 1
    };
    
    queue.writeTexture(&destination, pixels.ptr, pixels.len, &layout, &extent);
}
