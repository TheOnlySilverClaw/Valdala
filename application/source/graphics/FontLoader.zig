const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const TrueType = @import("TrueType");
const webgpu = @import("webgpu");
const zigimg = @import("zigimg");
const List = std.ArrayListUnmanaged;

pub fn loadFont(allocator: Allocator, file: []const u8, size: f32) !void {

    const font_bytes = try std.fs.cwd().readFileAlloc(allocator, file, 320 * 1024);
    defer allocator.free(font_bytes);

    const font = try TrueType.load(font_bytes);

    const alphabetSize = '~' - '!' + 1;
    var codePoints: [alphabetSize]u21 = undefined;
    for(&codePoints, 0..alphabetSize) |*c, i|{
        c.* = @as(u21, @intCast(i)) + @as(u21, '!');
    }

    const scale = font.scaleForPixelHeight(size);
    var pixels: List(List(u8)) = .empty;
    defer {
        for(pixels.items) |*sublist| {
            sublist.deinit(allocator);
        }
        pixels.deinit(allocator);
    }
    
    var maxWidth: u16 = 0;
    var maxHeight: u16 = 0;

    var bitmaps = try List(TrueType.GlyphBitmap).initCapacity(allocator, codePoints.len);
    defer bitmaps.deinit(allocator);

    // load individual bitmaps and figure out image dimensions
    for(codePoints) |codePoint| {
        const glyph = font.codepointGlyphIndex(codePoint).?;
        var glyphPixels: List(u8) = .empty;
        const bitmap = try font.glyphBitmap(
            allocator, &glyphPixels, glyph, scale, scale);
        try bitmaps.append(allocator, bitmap);
        try pixels.append(allocator, glyphPixels);
        maxWidth = @max(maxWidth, bitmap.width);
        maxHeight = @max(maxHeight, bitmap.height);
    }

    const totalWidth = maxWidth * codePoints.len;

    var imagePixels = try allocator.alloc(u8, totalWidth * maxHeight);
    defer allocator.free(imagePixels);
    
    // copy glyphs to image
    for(bitmaps.items, pixels.items, 0..alphabetSize) | bitmap, glyphPixels, codePointIndex | {

        const xStart = codePointIndex * maxWidth;
        for(0..bitmap.width) |x| {
            for(0..bitmap.height) |y| {
                const glyphPixelIndex = x + y * bitmap.width;
                const texturePixelIndex = xStart + x + y * totalWidth;
                imagePixels[texturePixelIndex] = glyphPixels.items[glyphPixelIndex];
            }
        }
    }

    var image = try zigimg.ImageUnmanaged.fromRawPixels(allocator,
    totalWidth, maxHeight, imagePixels, .grayscale8);
    defer image.deinit(allocator);

    try image.writeToFilePath(allocator, "alphabet.png", .{ .png = .{}});
}