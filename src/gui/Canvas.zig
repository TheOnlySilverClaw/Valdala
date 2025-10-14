const std = @import("std");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const Map = std.AutoHashMapUnmanaged;
const Text = @import("Text.zig");
const TextMesh = @import("TextMesh.zig");
const TextMesher = @import("TextMesher.zig");

const Self = @This();


allocator: Allocator,
surface: *const graphics.Surface,
// auto-hash does not work for struct with slice
texts: Map(*Text, *TextMesh) ,

pub fn init(allocator: Allocator, surface: *const graphics.Surface) !Self {

    return .{
        .allocator = allocator,
        .surface = surface,
        .texts = .empty
    };
}

pub fn deinit(self: *Self) void {

    var iterator = self.texts.iterator();
    while(iterator.next()) |entry| {
        self.allocator.destroy(entry.value_ptr.*);
    }
    self.texts.clearAndFree(self.allocator);
}

pub fn updateText(self: *Self, text: *Text) !void {
    
    if(self.texts.get(text)) |mesh| {
        mesh.destroy();
        mesh.* = try TextMesher.generate(self.allocator, self.surface, text.*);
    } else {
        const mesh = try self.allocator.create(TextMesh);
        mesh.* = try TextMesher.generate(self.allocator, self.surface, text.*);
        try self.texts.put(self.allocator, text, mesh);
    }
}
