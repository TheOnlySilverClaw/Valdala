const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const TrueType = @import("TrueType");
const webgpu = @import("webgpu");
const zigimg = @import("zigimg");
const List = std.ArrayListUnmanaged;
const Map = std.AutoHashMapUnmanaged;
const Grid2D = @import("common").Grid2D;

pub const CodePoint = u21;

pub const Glyph = struct {
    width: u16,
    height: u16,
    xOffset: i16,
    yOffset: i16,
    pixels: []u8
};

pub const Font = struct {

    allocator: Allocator,
    size: f32,
    scale: f32,
    glyphByCodePoint: *Map(CodePoint, Glyph),

    _data: []u8,
    _trueType: TrueType,

    pub fn init(allocator: Allocator, file: []const u8, size: f32) !Font {

        const data = try std.fs.cwd().readFileAlloc(allocator, file, 320 * 1024);
        const trueType = try TrueType.load(data);
        const scale = trueType.scaleForPixelHeight(size);
        const glyphByCodePoint = try allocator.create(Map(CodePoint, Glyph));
        glyphByCodePoint.* = .{};
        
        return .{
            .allocator = allocator,
            .size = size,
            .scale = scale,
            .glyphByCodePoint = glyphByCodePoint,
            ._data = data,
            ._trueType = trueType
        };
    }

    pub fn deinit(self: Font) void {

        self.allocator.free(self._data);
        var glyphIterator = self.glyphByCodePoint.valueIterator();
        while(glyphIterator.next()) |g| {
            self.allocator.free(g.pixels);
        }
        self.glyphByCodePoint.deinit(self.allocator);
        self.allocator.destroy(self.glyphByCodePoint);
    }

    const GlyphError = error { Unknown };

    pub fn loadCodePoints(self: *Font, codePoints: []CodePoint) !void {

        for(codePoints) |cp| {
            try self.loadGlyph(@intCast(cp));
        }
    }

    pub fn loadASCII(self: *Font) !void {

        for(33..127) |i| {
            try self.loadGlyph(@intCast(i));
        }
    }

    fn loadGlyph(self: *Font, codePoint: CodePoint) !void {

        const index = self._trueType.codepointGlyphIndex(codePoint) orelse return GlyphError.Unknown;
        var pixels: List(u8) = .empty;
        const bitmap = try self._trueType.glyphBitmap(
            self.allocator, &pixels, index, self.scale, self.scale);
        
        const slice = try pixels.toOwnedSlice(self.allocator);
        const glyph = Glyph {
            .width = bitmap.width,
            .height = bitmap.height,
            .xOffset = bitmap.off_x,
            .yOffset = bitmap.off_y,
            .pixels = slice
        };
        
        try self.glyphByCodePoint.put(self.allocator, @intCast(codePoint), glyph);
    }


    pub fn renderUTF8(self: *Font, text: []const u8) !@import("zigimg").ImageUnmanaged {

        const utf8 = try std.unicode.Utf8View.init(text);

        var textureWidth: usize = 0;
        var textureHeight: usize = 0;

        var iterator = utf8.iterator();
        while (iterator.nextCodepoint()) |codePoint| {
            if(codePoint == ' ') {
                const index = self._trueType.codepointGlyphIndex(codePoint).?;
                const advance = self._trueType.glyphHMetrics(index).advance_width;
                const scaledAdvance: i16 = @intFromFloat(self.scale * @as(f32, @floatFromInt(advance)));
                textureWidth = @intCast(@as(i32, @intCast(textureWidth)) + scaledAdvance);
                continue;
            }
            const glyph = self.glyphByCodePoint.get(codePoint) orelse return GlyphError.Unknown;
            textureWidth += @intCast(@as(i32, @intCast(glyph.width)) + glyph.xOffset);
            textureHeight = @max(textureHeight, glyph.height);
        }

        var textureGrid = try Grid2D(u8).init(self.allocator, textureWidth, textureHeight);

        var textureOffsetX: usize = 0;
        iterator.i = 0;

        while (iterator.nextCodepoint()) |codePoint| {

            if(codePoint == ' ') {
                textureOffsetX += 12;
                continue;
            }

            const glyph = self.glyphByCodePoint.get(codePoint) orelse return GlyphError.Unknown;
            const glyphGrid = Grid2D(u8).fromSlice(glyph.pixels, glyph.width, glyph.height);
            const glyphWidth: usize = @as(usize, @intCast(@as(i32, @intCast(glyph.width)) + glyph.xOffset));
            const textureOffsetY: usize = textureHeight - glyph.height;
            
            for(0..glyph.width) |x| {
                const offsetX = x + textureOffsetX;
                for(0..glyph.height) |y| {
                    textureGrid.set(offsetX, y + textureOffsetY, glyphGrid.get(x, y));
                }
            }
            textureOffsetX += glyphWidth;
        }

        return try @import("zigimg").ImageUnmanaged.fromRawPixelsOwned(textureWidth, textureHeight, textureGrid.values, .grayscale8);
    }
};
