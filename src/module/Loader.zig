const std = @import("std");
const fs = std.fs;
const yaml = @import("yaml");

const Allocator = std.mem.Allocator;
const Module = @import("Module.zig");

pub const Error = error {
    MissingName
};

const Self = @This();


const json_max_size = 1024 * 4;

allocator: Allocator,
root: fs.Dir,


pub fn init(allocator: Allocator, root: fs.Dir) !Self {
    return .{
        .allocator = allocator,
        .root = root
    };
}

pub fn loadModule(self: Self, path: []const u8) !*const Module {

    var arena = std.heap.ArenaAllocator.init(self.allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const module_directory = try self.root.openDir(path, .{ .iterate = true, .no_follow = true });
    var module_file = try module_directory.openFile("module.yaml", .{});
    var json_buffer: [json_max_size]u8 = undefined;
    const read_length = try module_file.readAll(&json_buffer);
   
    var module_yaml = yaml.Yaml { .source = json_buffer[0..read_length] };
    try module_yaml.load(allocator);
    defer module_yaml.deinit(allocator);
    
    const module_descriptor = module_yaml.docs.items[0].map;

    const module_name = if(module_descriptor.get("name")) |v| v.string else return Error.MissingName;

    const module = Module {
        .name = try self.allocator.dupe(u8, module_name),
        .tiles = .empty
    };

    const allocated = try self.allocator.create(Module);
    allocated.* = module;

    return allocated;
}