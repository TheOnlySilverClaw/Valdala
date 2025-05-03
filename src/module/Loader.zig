const std = @import("std");
const fs = std.fs;
const math = std.math;
const zigimg = @import("zigimg");
const log = std.log.scoped(.module_loader);


const Allocator = std.mem.Allocator;
const Yaml = @import("yaml").Yaml;
const Module = @import("Module.zig");
const Tile = @import("Tile.zig");
const List = std.ArrayListUnmanaged;

pub const Error = error {
    MissingName,
    Empty,
    TextureSize,
    InvalidDirectory
};

const Self = @This();

const Dscriptor = struct {
    const file_name = "module.yaml";
    const max_size = 4 * 1024;
};

allocator: Allocator,
root: fs.Dir,


pub fn init(allocator: Allocator, root: fs.Dir) !Self {
    return .{
        .allocator = allocator,
        .root = root
    };
}

pub fn loadModule(self: Self, id: []const u8) !*const Module {

    var arena = std.heap.ArenaAllocator.init(self.allocator);
    defer arena.deinit();

    const area_allocator = arena.allocator();

    const directory = try self.root.openDir(id , .{ .no_follow = true });
    
    var module_file = try directory.openFile(Dscriptor.file_name, .{});
    const module_descriptor = try loadYamlMap(area_allocator, module_file);
    module_file.close();

    const module_name = if(module_descriptor.get("name")) |value| try value.asString() else return Error.MissingName;

    const module = try self.allocator.create(Module);
    module.id = id;
    module.name = try self.allocator.dupe(u8, module_name);
    
    if(module_descriptor.get("tiles")) |tiles| {
        const tile_map = try tiles.asMap();
        module.tiles = try self.loadTiles( area_allocator, directory, tile_map);
    }

    return module;
}

fn loadTiles(self: Self, arena: Allocator, directory: fs.Dir, map: Yaml.Map) !List(*Tile) {
    
    var tiles = List(*Tile).empty;
    try tiles.ensureTotalCapacity(self.allocator, map.entries.len);

    var iterator = map.iterator();
    while(iterator.next()) |entry| {
        
        const file_name = try entry.value_ptr.asString();
        var file = try directory.openFile(file_name, .{});
        defer file.close();

        const parent_path = fs.path.dirname(file_name) orelse return Error.InvalidDirectory;

        const descriptor = try loadYamlMap(arena, file);
        const name = if(descriptor.get("name")) |name| try name.asString() else return Error.MissingName;

        const tile = try self.allocator.create(Tile);
        tile.id = try self.allocator.dupe(u8, entry.key_ptr.*);
        tile.name = try self.allocator.dupe(u8, name);

        if(descriptor.get("textures")) |textures| {
            const texture_map = try textures.asMap();
            const parent_directory = try directory.openDir(parent_path, .{ .no_follow = true });
            tile.textures = try self.loadTextures(parent_directory, texture_map);
        }
        

        tiles.appendAssumeCapacity(tile);
    }

    return tiles;
}

fn loadTextures(self: Self, directory: fs.Dir, map: Yaml.Map) !Tile.TextureMapping {


    var all: ?*Tile.Texture = null;
    if(map.get("all")) |value| {
        const name = try value.asString();
        all = try self.allocator.create(Tile.Texture);
        all.?.* = try self.loadTexture(directory, name);
    }

    var top: ?*Tile.Texture = null;
    if(map.get("top")) |value| {
        const name = try value.asString();
        top = try self.allocator.create(Tile.Texture);
        top.?.* = try self.loadTexture(directory, name);
    }

    var bottom: ?*Tile.Texture = null;
    if(map.get("bottom")) |value| {
        const name = try value.asString();
        bottom = try self.allocator.create(Tile.Texture);
        bottom.?.* = try self.loadTexture(directory, name);
    }

    var sides: []Tile.Texture = &.{};
    if(map.get("sides")) |value| {
        switch (value) {
            .string => {
                const name = value.string;
                const texture = try self.loadTexture(directory, name);
                sides = try self.allocator.alloc(Tile.Texture, 1);
                sides[0] = texture;
            },
            .list => {
                const items = value.list;
                sides = try self.allocator.alloc(Tile.Texture, items.len);
                for(value.list, 0..) |item, index| {
                    const name = try item.asString();
                    const texture = try self.loadTexture(directory, name);
                    sides[index] = texture;
                }
            },
            else => return Yaml.Error.TypeMismatch
        }
    }

    return .{
        .all = all,
        .top = top,
        .bottom = bottom,
        .sides = sides
    };
    
}

fn loadTexture(self: Self, directory: fs.Dir, name: []const u8) !Tile.Texture {
    
    var file = directory.openFile(name, .{}) catch |err| {
        if (err == fs.File.OpenError.FileNotFound) {
            log.debug("Could not open file: {s}", .{ name });
        }
        return err;
    };

    var image = try zigimg.ImageUnmanaged.fromFile(self.allocator, &file);
    file.close();

    try image.convert(self.allocator, .rgba32);

    return .{
        .width = math.cast(u16, image.width) orelse return Error.TextureSize,
        .height = math.cast(u16, image.height) orelse return Error.TextureSize,
        .pixels = image.pixels.rgba32,
    };
}

fn loadYamlItems(allocator: Allocator, file: fs.File) ![]Yaml.Value {
    
    const source = try file.readToEndAlloc(allocator, Dscriptor.max_size);
    var yaml = Yaml { .source = source };
    try yaml.load(allocator);
    return yaml.docs.items;
}

fn loadYamlMap(allocator: Allocator, file: fs.File) !Yaml.Map {
    
    const items = try loadYamlItems(allocator, file);
    if(items.len == 0) return Error.Empty;
    return try items[0].asMap();
}