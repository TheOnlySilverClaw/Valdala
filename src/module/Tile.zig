const std = @import("std");

const Allocator = std.mem.Allocator;
pub const Texture = @import("Texture.zig");

pub const ID = []const u8;
pub const Name = []const u8;

pub const TextureMapping = struct {
    all: ?*const Texture,
    top: ?*const Texture,
    bottom: ?*const Texture,
    sides: []const *Texture
};

const Self = @This();


id: ID,
name: Name,
textures: TextureMapping,

pub fn deinit(self: Self, allocator: Allocator) void {
    
    allocator.free(self.id);
    allocator.free(self.name);

    if(self.textures.all) |texture| {
        allocator.free(texture.pixels);
        allocator.destroy(texture);
    }

    if(self.textures.top) |texture| {
        allocator.free(texture.pixels);
        allocator.destroy(texture);
    }

    if(self.textures.bottom) |texture| {
        allocator.free(texture.pixels);
        allocator.destroy(texture);
    }

    for(self.textures.sides) |texture| {
        allocator.free(texture.pixels);
        allocator.destroy(texture);
    }
}