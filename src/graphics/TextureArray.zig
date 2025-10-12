const webgpu = @import("webgpu");

pub const Error = error {};

pub const Options = struct {
    label: webgpu.StringView,
    mip_levels: u32 = 1,
    samples: u32 = 1,
    view_formaats: []webgpu.texture.TextureFormat = &.{},
    usage: webgpu.texture.TextureUsage = .{
        .texture_binding = true,
        .copy_dst = true
    },
};

pub const ViewOptions = struct {
    label: webgpu.StringView,
    aspect: webgpu.texture.TextureAspect = .all,
    base_array_layer: u32 = 0,
    base_mip_level: u32 = 0,
    dimension: webgpu.texture_view.TextureViewDimension = .@"2d_array",
    usage: webgpu.texture.TextureUsage = .{ .texture_binding = true, .copy_dst = true }
};

const Self = @This();

// only support rgba for now
const channel_count = 4;

handle: *webgpu.texture.Texture,
queue: *webgpu.queue.Queue,


pub fn create(width: u32, height: u32, layers: u32, device: *webgpu.device.Device, options: Options) Self {

    const descriptor = webgpu.texture.TextureDescriptor {
        .label = options.label,
        .dimension = .@"2d",
        // TODO create a mapping to byte size, then write can support other formats
        .format = .rgba8_unorm_srgb,
        .mip_level_count = options.mip_levels,
        .size = .{
            .width = width,
            .height = height,
            .depth_or_array_layers = layers
        },
        .usage = options.usage,
        .view_format_count = options.view_formaats.len,
        .view_formats = options.view_formaats.ptr,
        .sample_count = options.samples
    };

    const handle = device.createTexture(&descriptor);
    const queue = device.getQueue();
    
    return .{
        .handle = handle,
        .queue = queue
    };
}

pub fn write(self: Self, layer: u32, content: []const u8) !void {
    try self.writeArea(0, 0, self.getWidth(), self.getHeight(), layer, content);
}

pub fn writeArea(self: Self, x: u32, y: u32, width: u32, height: u32, layer: u32, content: []const u8) !void {
    
    const destination = webgpu.texel.TexelCopyTextureInfo {
        .aspect = .all,
        .mip_level = 0,
        .origin = .{
            .x = x,
            .y = y,
            .z = layer
        },
        .texture = self.handle
    };

    const layout = webgpu.texel.TexelCopyBufferLayout {
        .offset = 0,
        .bytes_per_row = width * channel_count,
        .rows_per_image = height
    };

    const extent = webgpu.Extent3D {
        .width = width,
        .height = height,
        .depth_or_array_layers = 1
    };
    
    self.queue.writeTexture(&destination, content.ptr, content.len, &layout, &extent);
}

pub fn createView(self: Self, options: ViewOptions) *webgpu.texture_view.TextureView {

    const descriptor = webgpu.texture_view.TextureViewDescriptor {
        .array_layer_count = self.getLayers(),
        .aspect = options.aspect,
        .base_array_layer = options.base_array_layer,
        .base_mip_level = options.base_mip_level,
        .dimension = options.dimension,
        .format = self.getFormat(),
        .label = options.label,
        .usage = options.usage,
        .mip_level_count = self.getMipLevels()
    };

    return self.handle.createView(&descriptor);
}

pub fn getFormat(self: Self) webgpu.texture.TextureFormat {
    return self.handle.getFormat();
}

pub fn getWidth(self: Self) u32 {
    return self.handle.getWidth();
}

pub fn getHeight(self: Self) u32 {
    return self.handle.getHeight();
}

pub fn getLayers(self: Self) u32 {
    return self.handle.getDepthOrArrayLayers();
}

pub fn getMipLevels(self: Self) u32 {
    return self.handle.getMipLevelCount();
}

pub fn destroy(self: Self) void {
    self.handle.destroy();
    self.handle.release();
    self.queue.release();
}