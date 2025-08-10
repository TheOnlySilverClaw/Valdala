const std = @import("std");
const fs = std.fs;

const Yaml = @import("yaml").Yaml;
const zigimg = @import("zigimg");
const webgpu = @import("webgpu");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const Image = zigimg.ImageUnmanaged;
const List = std.ArrayList;

pub const Entry = struct {
    textures: TextureOffsets
};

pub const TextureOffsets = struct {
    single: u8,
    bottom: u8,
    side: u8
};
const Self = @This();

const texture_size = 8;
const file_size_limit = 256;

allocator: Allocator,
entries: List(Entry),
texture_array: graphics.TextureArray,
texture_counter: u32,

pub fn init(allocator: Allocator, device: *webgpu.Device, expected_entries: u32) !Self {

    const texture_array: graphics.TextureArray = undefined;
    texture_array.create(texture_size, texture_size, expected_entries, device, .{
        .label = webgpu.StringView.sized("tiles"),
        // TODO generate mip maps
        // .mip_levels = 4
    });

    return .{
        .allocator = allocator,
        .entries = .empty,
        .texture_array = texture_array,
        .texture_counter = 0
    };
}

pub fn loadTile(self: *Self, directory: fs.Dir, descriptor: Yaml.Map) !void {
    try loadTextures(self.allocator, directory, descriptor);
}

fn loadTextures(allocator: Allocator, directory: fs.Dir, map: Yaml.Map) !Entry.TextureOffsets {


    if(map.get("all")) |value| {
        try loadTexture(allocator, directory, try value.asString());
        return .{
            .top = 0,
            .bottom = 0,
            .side = 0
        };
    }

    if(map.contains("top") and map.contains("bottom") and map.contains("side")) {
        
        try loadTexture(allocator, directory, try map.get("top").?.asString());
        try loadTexture(allocator, directory, try map.get("bottom").?.asString());
        try loadTexture(allocator, directory, try map.get("side").?.asString());

        return .{
            .top = 0,
            .bottom = 1,
            .side = 2
        };
    }

    return error.MissingTextures;
}

fn loadTexture(self: *Self, directory: fs.Dir, path: []const u8) !u32 {
    
    var file = try directory.openFile(path, .{});
    defer file.close();

    var image = try Image.fromFile(self.allocator, file);
    try image.convert(self.allocator, .rgba32);
    defer self.allocator.free(image.pixels);

    try self.texture_array.write(self.texture_counter, image.pixels);
    const index = self.texture_counter;
    self.texture_counter += 1;
    return index;
}

pub fn deinit(self: Self) void {
    self.texture_array.destroy();
}