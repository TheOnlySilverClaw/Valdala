const std = @import("std");
const fs = std.fs;
const log = std.log.scoped(.server);

const World = @import("world").World;
const ModuleLoader = @import("module").Loader;


const Allocator = std.mem.Allocator;


pub const Error = error {

};

const Self = @This();

allocator: Allocator,
directory: fs.Dir,
module_loader: *ModuleLoader,
world: ?*World,

pub fn init(allocator: Allocator, directory: fs.Dir) !Self {

    const module_loader = try allocator.create(ModuleLoader);
    const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    module_loader.* = try ModuleLoader.init(allocator, module_directory);
    
    const module = try module_loader.loadModule("valdala");
    log.debug("module: {s} {s}", .{ module.id, module.name });
    for(module.tiles.items) |tile| {
        log.debug("tile {s}", .{ tile.id });
        if(tile.textures.all) |texture| {
            log.debug("texture: {d}*{d} {d}", .{ texture.width, texture.height, texture.pixels.len });
        }
    }
    // TODO why does this work?!
    allocator.destroy(module.arena);
    module.deinit();

    return .{
        .allocator = allocator,
        .directory = directory,
        .module_loader = module_loader,
        .world = null
    };
}

pub fn deinit(self: Self) void {
    self.allocator.destroy(self.module_loader);
}

pub fn launch(self: Self) Error!void {
    _ = self;
    log.info("Launching server", .{});
}