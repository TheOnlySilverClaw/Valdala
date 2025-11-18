const std = @import("std");
const fs = std.fs;
const math = std.math;
const zigimg = @import("zigimg");
const graphics = @import("graphics");
const umka = @import("umka");
const log = std.log.scoped(.module_loader);


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
    self.tile_registry.deinit();
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
    module.* = try Module.init(id, module_name_copy);
    
    if(module_descriptor.get("tiles")) |tiles| {
        // TODO error handling!
        const tile_map = tiles.asMap().?;
        try self.loadTiles(parser_allocator, directory, tile_map, module.umka_instance, id);
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

fn loadTiles(self: *Self, arena: Allocator, directory: fs.Dir, map: Yaml.Map, umka_instance: umka.Instance, module_id: []const u8) !void {
    
    var umka_module_arena = ArenaAllocator.init(self.allocator);
    defer umka_module_arena.deinit();
    const umka_module_allocator = umka_module_arena.allocator();

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

        if(descriptor.get("script")) |script_path| {
            const script_source = try loadScript(umka_module_allocator, parent_directory, script_path.asScalar().?);
            const script_source_c = @as([*:0]const u8, @ptrCast(script_source.ptr));
            log.debug("script source:\n{s}", .{ script_source_c });
            const umka_module_name = try toUmkaModuleName(umka_module_allocator, module_id, "tile", id_copy);
            log.debug("script module name: {s}", .{ umka_module_name.items });
            try umka_instance.addModule(@ptrCast(umka_module_name.items.ptr), @ptrCast(script_source_c));
        }
    }


    umka_instance.compile() catch {
        const err = umka_instance.getError();
        log.err("Failed to compile file {s} function {s} line {d} position {d}: {s}", .{ err.file_name, err.fn_name, err.line, err.pos, err.msg });
        return;
    };

    log.debug("asm:\n{s}", .{ umka_instance.assembly() });

    for(self.tile_registry.tiles.items) |*tile| {
        const umka_module_name = try toUmkaModuleName(umka_module_allocator, module_id, "tile", tile.id);
        const step_func = umka_instance.getFunc(@ptrCast(umka_module_name.items.ptr), "step");
        log.debug("module name: {s} found: {}", .{ umka_module_name.items, step_func != null});
        tile.behavior = .{
            .step = step_func
        };
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

fn loadScript(allocator: Allocator, directory: fs.Dir, path: []const u8) ![]const u8 {

    var file = try directory.openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const source_buffer = try allocator.alloc(u8, file_size + 1);
    _ = try file.readAll(source_buffer);
    source_buffer[file_size] = 0;
    return source_buffer;
}

fn toUmkaModuleName(allocator: Allocator, module_name: []const u8, type_name: []const u8, object_name: []const u8) !List(u8) {
    
    var bytes = try List(u8).initCapacity(allocator, module_name.len + type_name.len + object_name.len + 2 + 1);
    bytes.appendSliceAssumeCapacity(module_name);
    bytes.appendAssumeCapacity('/');
    bytes.appendSliceAssumeCapacity(type_name);
    bytes.appendAssumeCapacity('/');
    bytes.appendSliceAssumeCapacity(object_name);
    bytes.appendAssumeCapacity(0);
    return bytes;
}