const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const TrueType = @import("TrueType");
const webgpu = @import("webgpu");
const zigimg = @import("zigimg");
const List = std.ArrayListUnmanaged;
const Map = std.AutoHashMapUnmanaged;
const Grid2D = @import("common").Grid2D;

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
    pixelsByGlpyh: *Map(u32, Glyph),

    _xOffset: usize,
    _data: []u8,
    _trueType: TrueType,

    pub fn init(allocator: Allocator, file: []const u8, size: f32) !Font {

        const data = try std.fs.cwd().readFileAlloc(allocator, file, 320 * 1024);
        const trueType = try TrueType.load(data);
        const scale = trueType.scaleForPixelHeight(size);
        const pixelsByGlyph = try allocator.create(Map(u32, Glyph));
        pixelsByGlyph.* = .{};
        
        return .{
            .allocator = allocator,
            .size = size,
            .scale = scale,
            .pixelsByGlpyh = pixelsByGlyph,
            ._xOffset = 0,
            ._data = data,
            ._trueType = trueType
        };
    }

    pub fn deinit(self: Font) void {

        self.allocator.free(self._data);
        var glyphIterator = self.pixelsByGlpyh.valueIterator();
        while(glyphIterator.next()) |g| {
            self.allocator.free(g.pixels);
        }
        self.pixelsByGlpyh.deinit(self.allocator);
        self.allocator.destroy(self.pixelsByGlpyh);
    }

    const GlyphError = error { Unknown };

    pub fn loadCodePoints(self: *Font, codePoints: []u32) !void {

        for(codePoints) |cp| {
            try self.loadGlyph(@intCast(cp));
        }
    }

    pub fn loadASCII(self: *Font) !void {

        for(33..127) |i| {
            std.debug.print("{d}\n", .{i});
            try self.loadGlyph(@intCast(i));
        }
    }

    fn loadGlyph(self: *Font, codePoint: u21) !void {

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
        try self.pixelsByGlpyh.put(self.allocator, @intCast(codePoint), glyph);
    }
};
