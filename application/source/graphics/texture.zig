const std = @import("std");
const fs = std.fs;
const webgpu = @import("webgpu");
const img = @import("zigimg");
const binding = webgpu.texture;
const Allocator = std.mem.Allocator;
const Extent3D = webgpu.shared.Extent3D;
const Device = webgpu.device.Device;
const Queue = webgpu.queue.Queue;
const assert = std.debug.assert;

pub const texture_size_limit = 64 * 1024 * 1024;

pub const TextureError = error {
    LayersExceeded,
    ImageDimensionMismatch,
};

pub const TextureArray = struct {

    width: u32,
    height: u32,
    layers: u32,
    format: binding.TextureFormat,
    mip_levels: u32 = 1,
    samples: u32 = 1,
    label: ?[*:0]const u8 = null,

    handle: binding.Texture = undefined,

    pub fn create(self: *TextureArray, device: Device) void {

        const descriptor = binding.TextureDescriptor {
            .label = self.label,
            .dimension = .@"2d",
            .format = self.format,
            .mip_level_count = self.mip_levels,
            .size = .{
                .width = self.width,
                .height = self.height,
                .depth = self.layers
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

    pub fn loadImages(self: TextureArray, allocator: Allocator, queue: Queue, paths: []const []const u8) !void {

        if(paths.len > self.layers) return TextureError.LayersExceeded;

        for(paths, 0..) | path, layer| {
            try self.loadImage(allocator, queue, path, @intCast(layer));
        }
    }


    pub fn loadImage(self: TextureArray, allocator: Allocator, queue: Queue, path: []const u8, layer: u32) !void {

        if(layer >= self.layers) return TextureError.LayersExceeded;
        
        const encoded_bytes = try fs.cwd().readFileAlloc(allocator, path, texture_size_limit);
        defer allocator.free(encoded_bytes);

        var image = try img.ImageUnmanaged.fromMemory(allocator, encoded_bytes);
        defer image.deinit(allocator);

        if(image.width != @as(usize, self.width)) return TextureError.ImageDimensionMismatch;
        if(image.height != @as(usize, self.height)) return TextureError.ImageDimensionMismatch;

        // TODO map from surface texture format?
        try image.convert(allocator, .bgra32);

        const destination = binding.ImageCopyTexture {
            .aspect = .all,
            .mip_level = 0,
            .origin = .{
                .x = 0,
                .y = 0,
                .z = layer
            },
            .texture = self.handle
        };

        const layout = binding.TextureDataLayout {
            .offset = 0,
            .bytes_per_row = @intCast(image.rowByteSize()),
            .rows_per_image = self.height
        };

        const extent = Extent3D {
            .width = self.width,
            .height = self.height,
            .depth = 1
        };
        
        const pixel_bytes = image.pixels.asConstBytes();
        queue.writeTexture(&destination, pixel_bytes.ptr, pixel_bytes.len, &layout, &extent);
    }

    pub fn createView(self: TextureArray) binding.view.TextureView {
    
        const descriptor = binding.view.TextureViewDescriptor {
            .array_layer_count = self.layers,
            .aspect = .all,
            .base_array_layer = 0,
            .base_mip_level = 0,
            .dimension = .@"2d_array",
            .format = self.format,
            .label = self.label,
            .mip_level_count = self.mip_levels
        };

        return self.handle.createView(&descriptor);
    }
};