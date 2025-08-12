const std = @import("std");
const fs = std.fs;

const Yaml = @import("yaml").Yaml;
const zigimg = @import("zigimg");
const webgpu = @import("webgpu");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const Image = zigimg.ImageUnmanaged;
const List = std.ArrayListUnmanaged;
const Tile = @import("Tile.zig");

const Self = @This();

const texture_size = 8;
const file_size_limit = 256;

allocator: Allocator,
tiles: List(Tile),
texture_array: graphics.TextureArray,
texture_counter: u32,

pub fn init(allocator: Allocator, texture_array: graphics.TextureArray) !Self {

    return .{
        .allocator = allocator,
        .tiles = .empty,
        .texture_array = texture_array,
        .texture_counter = 0
    };
}

pub fn deinit(self: *Self) void {

    for(self.tiles.items) |tile| {
        tile.deinit(self.allocator);
    }

    self.tiles.clearAndFree(self.allocator);
    self.texture_array.destroy();
}

pub fn loadTile(self: *Self, directory: fs.Dir, id: Tile.ID, descriptor: Yaml.Map) !void {

    var tile: Tile = undefined;
    
    tile.id = id;

    const name = descriptor.get("name") orelse return error.MissingName;
    tile.name = try self.allocator.dupe(u8, try name.asString());
    
    const textures = descriptor.get("textures") orelse return error.MissingTextures;
    tile.textures = try self.loadTextures(directory, try textures.asMap());

    try self.tiles.append(self.allocator, tile);

}

fn loadTextures(self: *Self, directory: fs.Dir, map: Yaml.Map) !Tile.Textures {


    if(map.get("all")) |value| {
        try self.loadTexture(directory, try value.asString());
        return .{
            .top = 0,
            .bottom = 0,
            .side = 0
        };
    }

    if(map.contains("top") and map.contains("bottom") and map.contains("side")) {
        
        try self.loadTexture(directory, try map.get("top").?.asString());
        try self.loadTexture(directory, try map.get("bottom").?.asString());
        try self.loadTexture(directory, try map.get("side").?.asString());

        return .{
            .top = 0,
            .bottom = 1,
            .side = 2
        };
    }

    return error.MissingTextures;
}

fn loadTexture(self: *Self, directory: fs.Dir, path: []const u8) !void {
    
    var file = try directory.openFile(path, .{});
    defer file.close();

    var image = try Image.fromFile(self.allocator, &file);
    try image.convert(self.allocator, .rgba32);
    defer image.deinit(self.allocator);

    try self.texture_array.write(self.texture_counter, image.pixels.asConstBytes());
    self.texture_counter += 1;
}
