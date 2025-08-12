const std = @import("std");
const fs = std.fs;
const math = std.math;
const zigimg = @import("zigimg");
const log = std.log.scoped(.module_loader);
const graphics = @import("graphics");


const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const Yaml = @import("yaml").Yaml;
const List = std.ArrayListUnmanaged;
const Tile = @import("Tile.zig");
const TileRegistry = @import("TileRegistry.zig");
const TextureArray = graphics.TextureArray;
const Module = @import("LoadedModule.zig");

pub const Error = error {
    MissingName,
    Empty,
    TextureSize,
    InvalidDirectory
};

const Self = @This();

const Descriptor = struct {
    const file_name = "module.yaml";
    const max_size = 4 * 1024;
};

allocator: Allocator,
root: fs.Dir,
loaded: List(*Module),
tile_registry: TileRegistry,

pub fn init(allocator: Allocator, root: fs.Dir, tile_textures: TextureArray) !Self {
    
    const tile_registry = try TileRegistry.init(allocator, tile_textures);

    return .{
        .allocator = allocator,
        .root = root,
        .loaded = .empty,
        .tile_registry = tile_registry
    };
}

pub fn deinit(self: *Self) void {
    self.unloadModules();
}

pub fn loadModule(self: *Self, id: []const u8) !*const Module {

    // holds intermediate memory for loaded file formats
    var parser_arena = ArenaAllocator.init(self.allocator);
    defer parser_arena.deinit();
    const parser_allocator = parser_arena.allocator();

    const directory = try self.root.openDir(id , .{ .no_follow = true });
    
    var module_file = try directory.openFile(Descriptor.file_name, .{});
    const module_descriptor = try loadYamlMap(parser_allocator, module_file);
    module_file.close();

    const module_name = if(module_descriptor.get("name")) |value| try value.asString() else return Error.MissingName;
    const module_name_copy = try self.allocator.dupe(u8, module_name);

    const module = try self.allocator.create(Module);
    module.* = Module.init(id, module_name_copy);
    
    if(module_descriptor.get("tiles")) |tiles| {
        const tile_map = try tiles.asMap();
        module.tiles = try loadTiles( self.allocator, parser_allocator, directory, tile_map, self.tile_registry);
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

fn loadTiles(self: Self, arena: Allocator, directory: fs.Dir, map: Yaml.Map) !void {
    
    var iterator = map.iterator();
    while(iterator.next()) |entry| {
        
        const file_name = try entry.value_ptr.asString();
        var file = try directory.openFile(file_name, .{});
        defer file.close();

        const parent_path = fs.path.dirname(file_name) orelse return Error.InvalidDirectory;

        const id_copy = try self.allocator.dupe(u8, entry.key_ptr.*);
        const descriptor = try loadYamlMap(arena, file);    

        const parent_directory = try directory.openDir(parent_path, .{ .no_follow = true });
        try self.tile_registry.loadTile(parent_directory, id_copy, descriptor);
    }
}

fn loadYamlItems(allocator: Allocator, file: fs.File) ![]Yaml.Value {
    
    const source = try file.readToEndAlloc(allocator, Descriptor.max_size);
    var yaml = Yaml { .source = source };
    try yaml.load(allocator);
    return yaml.docs.items;
}

fn loadYamlMap(allocator: Allocator, file: fs.File) !Yaml.Map {
    
    const items = try loadYamlItems(allocator, file);
    if(items.len == 0) return Error.Empty;
    return try items[0].asMap();
}