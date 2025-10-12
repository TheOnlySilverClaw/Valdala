const std = @import("std");
const webgpu = @import("webgpu");
const algebra = @import("algebra");
const log = std.log.scoped(.font);

const Allocator = std.mem.Allocator;
const Vector = algebra.Vector2;
const TrueType = @import("TrueType");
const ImageTexture = @import("ImageTexture.zig");
const Map = std.AutoHashMapUnmanaged;
const List = std.ArrayListUnmanaged;

pub const Error = error {
    TextureSize,
    UnknownGlyph,
    DuplicateGlyph
};

pub const TextureSlice = struct {
    start_x: f32,
    start_y: f32,
    end_x: f32,
    end_y: f32
};

pub const Glyph = struct {
    offset_x: f32,
    offset_y: f32,
    width: f32,
    height: f32,
    advance: f32,
    texture_slice: TextureSlice
};

pub const CodePoint = u21;

pub const Size = f32;

const Self = @This();

const glyph_texture_padding = 1;
const texture_width_max = 255;
// bitmap saved in red channel
const texture_format = webgpu.texture.TextureFormat.r8_unorm;

allocator: Allocator,
trueType: TrueType,
height: Size,
scale: f32,
texture: ImageTexture,
glyphs: Map(CodePoint, Glyph),
texture_position: Vector(u32),

pub fn init(allocator: Allocator, device: *webgpu.device.Device, source: []const u8, height: Size, expected_glyphs: u32) !Self {

    if(height + glyph_texture_padding * 2 > texture_width_max) return Error.TextureSize;

    const trueType = try TrueType.load(source);
    const scale = trueType.scaleForPixelHeight(height);

    var glyphs = Map(CodePoint, Glyph).empty;
    try glyphs.ensureTotalCapacity(allocator, expected_glyphs);

    const required_area: f32 = height * @as(f32, @floatFromInt(expected_glyphs));
    const texture_width: f32 = @min(texture_width_max, required_area);
    const texture_height: f32 = @ceil(required_area / texture_width) * height;

    const texture = ImageTexture.create(device, @intFromFloat(texture_width), @intFromFloat(texture_height), .{
        .label = webgpu.StringView.sliced("font"),
        .format = texture_format,
    });

    const texture_position = Vector(u32).of(glyph_texture_padding, glyph_texture_padding);

    return .{
        .allocator = allocator,
        .trueType = trueType,
        .height = height,
        .scale = scale,
        .texture = texture,
        .glyphs = glyphs,
        .texture_position = texture_position
    };
}

pub fn deinit(self: *Self) void {

    self.glyphs.deinit(self.allocator);
    self.texture.destroy();
}

pub fn loadASCII(self: *Self) !void {

    for(33..127) |i| {
        const code_point: CodePoint = @intCast(i);
        _ = try self.loadGlyph(code_point);
    }
}

pub fn getGlyph(self: *Self, code_point: CodePoint) !Glyph {

    return self.glyphs.get(code_point) orelse {
        try self.loadGlyph(code_point);
        return self.glyphs.get(code_point).?;
    };
}

fn loadGlyph(self: *Self, code_point: CodePoint) !void {

    if(self.glyphs.contains(code_point)) return Error.DuplicateGlyph;

    const index = self.trueType.codepointGlyphIndex(code_point) orelse return Error.UnknownGlyph;

    var pixels = List(u8).empty;
    const bitmap = try self.trueType.glyphBitmap(self.allocator, &pixels, index, self.scale, self.scale);
    
    if(self.texture_position.x + bitmap.width > texture_width_max) {
        self.texture_position.x = glyph_texture_padding;
        self.texture_position.y += @as(u32, @intFromFloat(self.height)) + glyph_texture_padding;
    }

    try self.texture.writeRectangle(pixels.items, self.texture_position.x, self.texture_position.y, bitmap.width, bitmap.height);
    pixels.deinit(self.allocator);

    const texture_slice = calculateTextureSlice(self.texture, bitmap, @floatFromInt(self.texture_position.x), @floatFromInt(self.texture_position.y));
    const metrics = self.trueType.glyphHMetrics(index);

    const glyph = Glyph {
        .offset_x = @floatFromInt(bitmap.off_x),
        .offset_y = @floatFromInt(bitmap.off_y),
        .width = @floatFromInt(bitmap.width),
        .height = @floatFromInt(bitmap.height),
        .advance = @as(f32, @floatFromInt(metrics.advance_width)) * self.scale,
        .texture_slice = texture_slice
    };

    try self.glyphs.put(self.allocator, code_point, glyph);
    
    self.texture_position.x += bitmap.width + glyph_texture_padding;
}


fn calculateTextureSlice(texture: ImageTexture, bitmap: TrueType.GlyphBitmap, start_x: f32, start_y: f32) TextureSlice {

    const texture_width: f32 = @floatFromInt(texture.getWidth());
    const texture_height: f32 = @floatFromInt(texture.getHeight());

    const glyph_width: f32 = @floatFromInt(bitmap.width);
    const glyph_height: f32 = @floatFromInt(bitmap.height);

    return .{
        .start_x = start_x / texture_width,
        .start_y = start_y / texture_height,
        .end_x = (start_x + glyph_width) / texture_width,
        .end_y = (start_y + glyph_height) / texture_height
    };
}