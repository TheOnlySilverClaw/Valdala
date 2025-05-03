pub const Texture = @import("Texture.zig");

pub const ID = []const u8;
pub const Name = []const u8;

pub const TextureMapping = struct {
    all: ?*const Texture,
    top: ?*const Texture,
    bottom: ?*const Texture,
    sides: []const Texture
};

id: ID,
name: Name,
textures: TextureMapping,
