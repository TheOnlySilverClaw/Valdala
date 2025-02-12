const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Pipeline = @import("TextRenderPipeline.zig");
const Color = @import("Color.zig").Color(u8);
const Surface = @import("Surface.zig");
const Shader = @import("shader.zig").Shader;
const Font = @import("Font.zig");
const ImageTexture = @import("ImageTexture.zig");

const Self = @This();

pipeline: Pipeline,
font: Font,
glyphTexture: ImageTexture,
surface: Surface,
lastGlyphStart: u32,

pub fn init(allocator: Allocator, surface: Surface) !Self {

    const device = surface.device;

    const shader = try Shader.loadModule(allocator, device, "shaders/text.wgsl", "text");

    const pipeline = Pipeline.create(device, surface.colorTextureFormat, shader);

    var font = try Font.init(allocator, "fonts/FiraCode/FiraCode-Regular.ttf", 16);
    try font.loadASCII();

    // reserve maximum width for all glpyhs
    // TODO estimate for non-ASCII fonts with lazy-loaded glyphs
    const fontHeight: u32 = @intFromFloat(@ceil(font.size));
    const textureWidth = font.glyphByCodePoint.size * fontHeight;

    var glyphTexture = ImageTexture {
        .format = .r8_unorm,
        .height = fontHeight,
        .width = textureWidth,
        .label = "glyphs",
        .mipLevels = 1,
        .samples = 1
    };
    glyphTexture.create(surface.device);

    return .{
        .pipeline = pipeline,
        .font = font,
        .glyphTexture = glyphTexture,
        .surface = surface,
        .lastGlyphStart = 0
    };
}

pub fn loadFontTexture(self: *Self) !void {

    var iterator = self.font.glyphByCodePoint.valueIterator();
    while (iterator.next()) |glpyh| {
        try self.loadGlyphPixels(glpyh);   
    }
}

fn loadGlyphPixels(self: *Self, glyph: *Font.Glyph) !void {

    if(glyph.pixels) |pixels| {

        try self.glyphTexture.loadImagePixelsRectangle(
            pixels, self.surface.getQueue(), self.lastGlyphStart, 0, glyph.width, glyph.height);
        
        self.lastGlyphStart += glyph.width;
    }
}

pub fn deinit(self: Self) void {

    self.font.deinit();
}

pub fn render(self: Self, delta: u64) !void {

    _ = self;
    _ = delta;
}