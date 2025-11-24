const std = @import("std");
const fs = std.fs;
const math = std.math;
const zigimg = @import("zigimg");
const graphics = @import("graphics");
const log = std.log.scoped(.module_loader);


const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const List = std.ArrayListUnmanaged;
const Yaml = @import("yaml").Yaml;
const Gltf = @import("zgltf").Gltf;
const Tile = @import("Tile.zig");
const TileRegistry = @import("TileRegistry.zig");
const TextureArray = graphics.TextureArray;
const TextureList = graphics.TextureList;
const Module = @import("LoadedModule.zig");
const EntityRegistry = @import("EntityRegistry.zig");

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
entity_registry: EntityRegistry,

pub fn init(allocator: Allocator, root: fs.Dir, tile_textures: TextureArray, entity_textures: TextureList) !Self {
    
    const tile_registry = try TileRegistry.init(allocator, tile_textures);
    const entity_registry = EntityRegistry.init(allocator, entity_textures);

    return .{
        .allocator = allocator,
        .root = root,
        .loaded = .empty,
        .tile_registry = tile_registry,
        .entity_registry = entity_registry
    };
}

pub fn deinit(self: *Self) void {
    
    self.tile_registry.deinit();
    self.entity_registry.deinit();
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

    // TODO error handling!
    const module_name = module_descriptor.get("name").?.asScalar().?;

    const module_name_copy = try self.allocator.dupe(u8, module_name);

    const module = try self.allocator.create(Module);
    module.* = Module.init(id, module_name_copy);
    
    if(module_descriptor.get("tiles")) |tiles| {
        switch (tiles) {
            .map => |map| {
            try self.loadTiles(parser_allocator, directory, map);
        },
        // TODO error reporting
        else => {}
        }
    }

    if(module_descriptor.get("entities")) |entities| {
        switch (entities) {
            .map => |map| {
                try self.loadEntities(parser_allocator, directory, map);
            },
            // TODO error reporting
            else => {}
        }
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

fn loadTiles(self: *Self, arena: Allocator, directory: fs.Dir, map: Yaml.Map) !void {
    
    var iterator = map.iterator();
    while(iterator.next()) |entry| {
        
        // TODO error handling!
        const file_name = entry.value_ptr.asScalar().?;
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
    return items[0].asMap() orelse Error.Empty;
}

fn loadEntities(self: *Self, arena: Allocator, directory: fs.Dir, map: Yaml.Map) !void {
    
    var iterator = map.iterator();
    while(iterator.next()) |entry| {
        
        // TODO error handling!
        const file_name = entry.value_ptr.asScalar().?;
        var file = try directory.openFile(file_name, .{});
        defer file.close();

        const parent_path = fs.path.dirname(file_name) orelse return Error.InvalidDirectory;

        const id_copy = try self.allocator.dupe(u8, entry.key_ptr.*);
        const descriptor = try loadYamlMap(arena, file);

        const parent_directory = try directory.openDir(parent_path, .{ .no_follow = true });
        try self.entity_registry.load(parent_directory, id_copy, descriptor);
    }
}

