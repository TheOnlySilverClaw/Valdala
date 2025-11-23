const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const ImageTexture = @import("ImageTexture.zig");

const Self = @This();

allocator: Allocator,
device: *webgpu.device.Device,
queue: *webgpu.queue.Queue,
textures: List(ImageTexture),

pub fn init(allocator: Allocator, device: *webgpu.device.Device) Self {
    return .{
        .allocator = allocator,
        .device = device,
        .queue = device.getQueue(),
        .textures = .empty
    };
}

pub fn deinit(self: *Self) void {
    
    self.queue.release();
    for(self.textures.items) |texture| {
        texture.destroy();
    }
    self.textures.clearAndFree(self.allocator);
}

pub fn add(self: *Self, width: u32, height: u32, content: []const u8) !u32 {

    const texture = ImageTexture.create(self.device, width, height, .{ .format = .rgba8_unorm_srgb });
    texture.write(content);
    const index: u32 = @intCast(self.textures.items.len);
    try self.textures.append(self.allocator, texture);
    return index;
}