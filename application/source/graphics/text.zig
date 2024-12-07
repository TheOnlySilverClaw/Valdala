
// const font_bytes = try std.fs.cwd().readFileAlloc(allocator, "fonts/FiraCode/FiraCode-Regular.ttf", 320 * 1024);
// defer allocator.free(font_bytes);

// const font = try TrueType.load(font_bytes);

// var iterator = code_points.iterator();
// const cp = iterator.nextCodepoint().?;
// const scale = font.scaleForPixelHeight(16);
// const glyph = font.codepointGlyphIndex(cp).?;
// var pixels: std.ArrayListUnmanaged(u8) = .empty;
// const bitmap = try font.glyphBitmap(allocator, &pixels, glyph, scale, scale);
// defer pixels.deinit(allocator);
