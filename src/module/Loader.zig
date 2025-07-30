const std = @import("std");
const fs = std.fs;
const math = std.math;
const zigimg = @import("zigimg");
const log = std.log.scoped(.module_loader);


const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const Yaml = @import("yaml").Yaml;
const Module = @import("LoadedModule.zig");
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
loaded: List(*Module),

pub fn init(allocator: Allocator, root: fs.Dir) !Self {
    return .{
        .allocator = allocator,
        .root = root,
        .loaded = List(*Module).empty
    };
}

pub fn loadModule(self: *Self, id: []const u8) !*const Module {

    // holds intermediate memory for loaded file formats
    var parser_arena = ArenaAllocator.init(self.allocator);
    defer parser_arena.deinit();
    const parser_allocator = parser_arena.allocator();

    const directory = try self.root.openDir(id , .{ .no_follow = true });
    
    var module_file = try directory.openFile(Dscriptor.file_name, .{});
    const module_descriptor = try loadYamlMap(parser_allocator, module_file);
    module_file.close();

    const module_name = if(module_descriptor.get("name")) |value| try value.asString() else return Error.MissingName;

    const module = try self.allocator.create(Module);
    module.* = Module.init(id);
    module.name = try self.allocator.dupe(u8, module_name);
    
    if(module_descriptor.get("tiles")) |tiles| {
        const tile_map = try tiles.asMap();
        module.tiles = try loadTiles( self.allocator, parser_allocator, directory, tile_map);
    }

    try self.loaded.append(self.allocator, module);
    return module;
}

pub fn unloadModules(self: *Self) void {

    for(self.loaded.items) |module| {
        module.deinit(self.allocator);
        self.allocator.destroy(module);
    }
    self.loaded.clearAndFree(self.allocator);
}

fn loadTiles(module_allocator: Allocator, arena: Allocator, directory: fs.Dir, map: Yaml.Map) !List(*Tile) {
    
    var tiles = List(*Tile).empty;
    try tiles.ensureTotalCapacity(module_allocator, map.entries.len);

    var iterator = map.iterator();
    while(iterator.next()) |entry| {
        
        const file_name = try entry.value_ptr.asString();
        var file = try directory.openFile(file_name, .{});
        defer file.close();

        const parent_path = fs.path.dirname(file_name) orelse return Error.InvalidDirectory;

        const descriptor = try loadYamlMap(arena, file);
        const name = if(descriptor.get("name")) |name| try name.asString() else return Error.MissingName;

        const tile = try module_allocator.create(Tile);
        tile.id = try module_allocator.dupe(u8, entry.key_ptr.*);
        tile.name = try module_allocator.dupe(u8, name);

        if(descriptor.get("textures")) |textures| {
            const texture_map = try textures.asMap();
            const parent_directory = try directory.openDir(parent_path, .{ .no_follow = true });
            tile.textures = try loadTextures(module_allocator, parent_directory, texture_map);
        }
        
        tiles.appendAssumeCapacity(tile);
    }

    return tiles;
}

fn loadTextures(allocator: Allocator, directory: fs.Dir, map: Yaml.Map) !Tile.TextureMapping {


    var all: ?*Tile.Texture = null;
    if(map.get("all")) |value| {
        const name = try value.asString();
        all = try allocator.create(Tile.Texture);
        all.?.* = try loadTexture(allocator, directory, name);
    }

    var top: ?*Tile.Texture = null;
    if(map.get("top")) |value| {
        const name = try value.asString();
        top = try allocator.create(Tile.Texture);
        top.?.* = try loadTexture(allocator, directory, name);
    }

    var bottom: ?*Tile.Texture = null;
    if(map.get("bottom")) |value| {
        const name = try value.asString();
        bottom = try allocator.create(Tile.Texture);
        bottom.?.* = try loadTexture(allocator, directory, name);
    }

    var sides: []*Tile.Texture = &.{};
    if(map.get("sides")) |value| {
        switch (value) {
            .string => {
                const name = value.string;
                const texture = try loadTexture(allocator, directory, name);
                sides = try allocator.alloc(*Tile.Texture, 1);
                sides[0].* = texture;
            },
            .list => {
                const items = value.list;
                sides = try allocator.alloc(*Tile.Texture, items.len);
                for(value.list, 0..) |item, index| {
                    const name = try item.asString();
                    const texture = try loadTexture(allocator, directory, name);
                    sides[index].* = texture;
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

fn loadTexture(allocator: Allocator, directory: fs.Dir, name: []const u8) !Tile.Texture {
    
    var file = directory.openFile(name, .{}) catch |err| {
        if (err == fs.File.OpenError.FileNotFound) {
            log.debug("Could not open file: {s}", .{ name });
        }
        return err;
    };

    var image = try zigimg.ImageUnmanaged.fromFile(allocator, &file);
    file.close();

    try image.convert(allocator, .rgba32);

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