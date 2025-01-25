const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const TrueType = @import("TrueType");
const webgpu = @import("webgpu");
const zigimg = @import("zigimg");
const List = std.ArrayListUnmanaged;
const Map = std.AutoHashMapUnmanaged;
const Grid2D = @import("common").Grid2D;
const Image = @import("zigimg").ImageUnmanaged;
const Color = @import("color.zig").Color;

pub const CodePoint = u21;

pub const Glyph = struct {
    width: u16,
    height: u16,
    offsetX: i16,
    offsetY: i16,
    advance: i16,
    pixels: ?[]u8
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
            if(g.pixels) |pixels| {
                self.allocator.free(pixels);
            }
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

        for(32..127) |i| {
            try self.loadGlyph(@intCast(i));
        }
    }


    fn loadGlyph(self: *Font, codePoint: CodePoint) !void {

        const trueType = self._trueType;
        const index = trueType.codepointGlyphIndex(codePoint) orelse return GlyphError.Unknown;
        var pixels: List(u8) = .empty;
        
        const metrics = trueType.glyphHMetrics(index);
        // advance seem to be the same for all?
        const advance: i16 = @intFromFloat(self.scale * @as(f32, @floatFromInt(metrics.advance_width)));
        var glyph: Glyph = undefined;
        
        if(trueType.glyphBitmap(self.allocator, &pixels, index, 
            self.scale, self.scale)) |bitmap| {
            
            const slice = try pixels.toOwnedSlice(self.allocator);
            glyph = .{
                .width = bitmap.width,
                .height = bitmap.height,
                .offsetX = bitmap.off_x,
                .offsetY = bitmap.off_y,
                .advance = advance,
                .pixels = slice
            };
        } else |_| {
            glyph = .{
                .width = 0,
                .height = 0,
                .offsetX = 0,
                .offsetY = 0,
                .advance = advance,
                .pixels = null
            };
        }
        
        try self.glyphByCodePoint.put(self.allocator, @intCast(codePoint), glyph);
    }


    pub fn renderUTF8(self: *Font, text: []const u8, color: Color(f32)) !Image {

        const utf8 = try std.unicode.Utf8View.init(text);

        var textureWidth: usize = 0;
        var textureHeight: usize = 0;

        var iterator = utf8.iterator();
        while (iterator.nextCodepoint()) |codePoint| {
            const glyph = self.glyphByCodePoint.get(codePoint) orelse return GlyphError.Unknown;
            textureWidth += @intCast(glyph.advance);
            textureHeight = @max(textureHeight, glyph.height);
        }

        var textureGrid = try Grid2D(u8).init(self.allocator, textureWidth, textureHeight);
        @memset(textureGrid.values, 0);

        var textureOffsetX: usize = 0;
        iterator.i = 0;

        while (iterator.nextCodepoint()) |codePoint| {

            const glyph = self.glyphByCodePoint.get(codePoint) orelse return GlyphError.Unknown;
            
            if(glyph.pixels) |pixels| {
                
                const glyphGrid = Grid2D(u8).fromSlice(pixels, glyph.width, glyph.height);
                const textureOffsetY: usize = textureHeight - glyph.height;
                
                for(0..glyph.width) |x| {
                    const offsetX = x + textureOffsetX;
                    for(0..glyph.height) |y| {
                        textureGrid.set(offsetX, y + textureOffsetY, glyphGrid.get(x, y));
                    }
                }
            }
            textureOffsetX += @intCast(glyph.advance);
        }

        const colorPixels: []u8 = try self.allocator.alloc(u8, textureGrid.size() * 4);
        
        for(0..textureWidth) |x| {
            for(0..textureHeight) |y| {
                const target = (x + y * textureWidth) * 4;
                const value: f32 = @floatFromInt(textureGrid.get(x, y));
                colorPixels[target + 0] = @intFromFloat(color.red * value);
                colorPixels[target + 1] = @intFromFloat(color.green * value);
                colorPixels[target + 2] = @intFromFloat(color.blue * value);
                colorPixels[target + 3] = @intFromFloat(color.alpha * value);

            }
        }
        textureGrid.deinit(self.allocator);

        return try Image.fromRawPixelsOwned(textureWidth, textureHeight, colorPixels, .rgba32);
    }
};
