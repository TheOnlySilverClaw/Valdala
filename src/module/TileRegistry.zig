const std = @import("std");
const fs = std.fs;

const Yaml = @import("yaml").Yaml;
const zigimg = @import("zigimg");
const webgpu = @import("webgpu");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const Image = zigimg.Image;
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

    var tiles = try List(Tile).initCapacity(allocator, 64);
    const air = Tile {
        .id = try allocator.dupe(u8, "air"),
        .name = try allocator.dupe(u8, "Air"),
        .textures = undefined
    };
    tiles.appendAssumeCapacity(air);

    return .{
        .allocator = allocator,
        .tiles = tiles,
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

pub fn getTile(self: Self, index: u32) Tile {
    return self.tiles.items[index];
}

pub fn loadTile(self: *Self, directory: fs.Dir, id: Tile.ID, descriptor: Yaml.Map) !void {

    var tile: Tile = undefined;
    
    tile.id = id;

    const name = descriptor.get("name") orelse return error.MissingName;
    // TODO error handling!
    tile.name = try self.allocator.dupe(u8, name.asScalar().?);
    
    const textures = descriptor.get("textures") orelse return error.MissingTextures;
    // TODO error handling!
    tile.textures = try self.loadTextures(directory, textures.asMap().?);

    try self.tiles.append(self.allocator, tile);

}

fn loadTextures(self: *Self, directory: fs.Dir, map: Yaml.Map) !Tile.Textures {


    if(map.get("all")) |value| {
        // TODO error handling!
        const index = try self.loadTexture(directory, value.asScalar().?);
        return .{
            .top = index,
            .bottom = index,
            .side = index
        };
    }

    if(map.contains("top") and map.contains("bottom") and map.contains("side")) {
        // TODO error handling!
        const top_index = try self.loadTexture(directory, map.get("top").?.asScalar().?);
        const bottom_index = try self.loadTexture(directory, map.get("bottom").?.asScalar().?);
        const side_index = try self.loadTexture(directory, map.get("side").?.asScalar().?);

        return .{
            .top = top_index,
            .bottom = bottom_index,
            .side = side_index
        };
    }

    return error.MissingTextures;
}

fn loadTexture(self: *Self, directory: fs.Dir, path: []const u8) !u32 {
    
    var file = try directory.openFile(path, .{});
    defer file.close();

    var read_buffer: [1024 * 10]u8 = undefined;
    var image = try Image.fromFile(self.allocator, file, &read_buffer);
    try image.convert(self.allocator, .rgba32);
    defer image.deinit(self.allocator);

    try self.texture_array.write(self.texture_counter, image.pixels.asConstBytes());
    const index = self.texture_counter;
    self.texture_counter += 1;
    return index;
}
