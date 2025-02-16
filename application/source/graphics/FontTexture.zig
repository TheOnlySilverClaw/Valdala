const std = @import("std");
const webgpu = @import("webgpu");
const TrueType = @import("TrueType");

const Allocator = std.mem.Allocator;
const ImageTexture = @import("ImageTexture.zig");
const HashMap = std.AutoHashMapUnmanaged;
const ArrayList = std.ArrayListUnmanaged;

pub const Error = error {
    TextureSize,
    UnknownGlyph,
    DuplicateGlyph
};

pub const TextureSlice = struct {
    startX: f32,
    startY: f32,
    endX: f32,
    endY: f32
};

pub const Glyph = struct {
    offsetX: f32,
    offsetY: f32,
    width: f32,
    height: f32,
    advance: f32,
    textureSlice: TextureSlice
};

pub const CodePoint = u21;

const Self = @This();


const maxTextureWidth = 255.0;
// bitmap saved in red channel
const textureFormat = webgpu.TextureFormat.r8_unorm;

allocator: Allocator,
queue: webgpu.Queue,
trueType: TrueType,
fontHeight: f32,
fontScale: f32,
texture: ImageTexture,
glyphByCodePoint: HashMap(CodePoint, Glyph),

offsetX: u32,
offsetY: u32,

pub fn init(allocator: Allocator, device: webgpu.Device, fontBytes: []const u8, fontHeight: f32, expectedGlyphs: u32) !Self {

    if(fontHeight > maxTextureWidth) return Error.TextureSize;

    const trueType = try TrueType.load(fontBytes);
    const fontScale = trueType.scaleForPixelHeight(fontHeight);

    var glyphByCodePoint = HashMap(CodePoint, Glyph) {};
    try glyphByCodePoint.ensureTotalCapacity(allocator, expectedGlyphs);

    const requiredSize: f32 = fontHeight * @as(f32, @floatFromInt(expectedGlyphs));
    const width: f32 = @min(maxTextureWidth, requiredSize);
    const height: f32 = @ceil(requiredSize / width) * fontHeight;

    var texture = ImageTexture {
        .label = "font glyphs",
        .format = textureFormat,
        .width = @intFromFloat(width),
        .height = @intFromFloat(height),
        .mipLevels = 1,
        .samples = 1
    };

    texture.create(device);

    const queue = device.getQueue();

    return .{
        .allocator = allocator,
        .queue = queue,
        .trueType = trueType,
        .fontHeight = fontHeight,
        .fontScale = fontScale,
        .texture = texture,
        .glyphByCodePoint = glyphByCodePoint,
        .offsetX = 0,
        .offsetY = 0
    };
}

pub fn deinit(self: *Self) void {

    self.allocator.free(self.trueType.ttf_bytes);

    self.glyphByCodePoint.deinit(self.allocator);

    self.texture.destroy();
    self.queue.release();
}

pub fn createView(self: Self) webgpu.TextureView {
    return self.texture.createView();
}

pub fn loadASCII(self: *Self) !void {

    for(33..127) |i| {
        const codePoint: CodePoint = @intCast(i);
        _ = try self.loadGlyph(codePoint);
    }
}

pub fn getGlyph(self: *Self, codeCpoint: CodePoint) !Glyph {

    return self.glyphByCodePoint.get(codeCpoint) orelse {
        std.log.debug("load new glyph {c}", .{ @as(u8, @intCast(codeCpoint)) });
        try self.loadGlyph(codeCpoint);
        return self.glyphByCodePoint.get(codeCpoint).?;
    };
}

fn loadGlyph(self: *Self, codeCoint: CodePoint) !void {

    if(self.glyphByCodePoint.contains(codeCoint)) return Error.DuplicateGlyph;

    const index = self.trueType.codepointGlyphIndex(codeCoint) orelse return Error.UnknownGlyph;

    var pixels = ArrayList(u8).empty;
    const bitmap = try self.trueType.glyphBitmap(self.allocator, &pixels, index, self.fontScale, self.fontScale);
    
    try self.texture.loadImagePixelsRectangle(pixels.items, self.queue, self.offsetX, self.offsetY, bitmap.width, bitmap.height);
    pixels.deinit(self.allocator);

    const textureSlice = calculateTextureSlice(self.texture, bitmap, @floatFromInt(self.offsetX), @floatFromInt(self.offsetY));
    const horizontalMetrics = self.trueType.glyphHMetrics(index);

    const glyph = Glyph {
        .offsetX = @floatFromInt(bitmap.off_x),
        .offsetY = @floatFromInt(bitmap.off_y),
        .width = @floatFromInt(bitmap.width),
        .height = @floatFromInt(bitmap.height),
        .advance = @as(f32, @floatFromInt(horizontalMetrics.advance_width)) * self.fontScale,
        .textureSlice = textureSlice
    };

    try self.glyphByCodePoint.put(self.allocator, codeCoint, glyph);
    
    self.offsetX = self.offsetX + bitmap.width + 1;
}


fn calculateTextureSlice(texture: ImageTexture, bitmap: TrueType.GlyphBitmap, startX: f32, startY: f32) TextureSlice {

    const textureWidth: f32 = @floatFromInt(texture.width);
    const textureHeight: f32 = @floatFromInt(texture.height);

    const glyphWidth: f32 = @floatFromInt(bitmap.width);
    const glyphHeight: f32 = @floatFromInt(bitmap.height);

    return .{
        .startX = startX / textureWidth,
        .startY = startY / textureWidth,
        .endX = (startX + glyphWidth) / textureWidth,
        .endY = (startY + glyphHeight) / textureHeight
    };
}