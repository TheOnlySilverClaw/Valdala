const std = @import("std");
const graphics = @import("graphics");
const algebra = @import("algebra");

const assert = std.debug.assert;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayListUnmanaged;
const Font = graphics.Font;
const Vector = algebra.Vector2;
const Color = graphics.color.RGBA;


pub const default_size: Font.Size = 16.0;
pub const default_color = Color.of(0.0, 0.0, 0.0, 1.0);

value: []const u8,
font: *Font,
position: Vector(u32),
size: Font.Size = default_size,
color: Color = default_color
