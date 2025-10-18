const std = @import("std");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const List = std.ArrayListUnmanaged;
const Text = @import("Text.zig");
const TextMesh = @import("TextMesh.zig");
const TextMesher = @import("TextMesher.zig");
const Vector = @import("algebra").Vector2;

pub const TextElement = struct {
    text: Text,
    mesh: TextMesh
};

const Self = @This();


allocator: Allocator,
surface: *const graphics.Surface,
// auto-hash does not work for struct with slice
texts: List(*TextElement) ,

pub fn init(allocator: Allocator, surface: *const graphics.Surface) !Self {

    return .{
        .allocator = allocator,
        .surface = surface,
        .texts = .empty
    };
}

pub fn deinit(self: *Self) void {

    for(self.texts.items) |text| {
        self.allocator.destroy(text);
    }
    self.texts.clearAndFree(self.allocator);
}

pub fn createText(self: *Self, text: Text) !*TextElement {
    
    const element = try self.allocator.create(TextElement);
    const mesh = try TextMesher.generate(self.allocator, self.surface, text);
    element.* = TextElement {
        .text = text,
        .mesh = mesh
    };
    try self.texts.append(self.allocator, element);
    return element;
}

pub fn updateText(self: *Self, element: *TextElement) !void {
    element.mesh.destroy();
    element.mesh = try TextMesher.generate(self.allocator, self.surface, element.text);
}