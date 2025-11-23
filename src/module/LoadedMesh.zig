const std = @import("std");

const Allocator = std.mem.Allocator;
const Image = @import("zigimg").Image;

const Self = @This();


positions: []const f32,
indices: []const u16,
textcoords: ?[]const f32,
color_texture: ?u32,


pub fn deinit(self: *Self, allocator: Allocator) void {
    
    allocator.free(self.positions);
    allocator.free(self.indices);
    
    if(self.textcoords) |texcoords| {
        allocator.free(texcoords);
    }
}