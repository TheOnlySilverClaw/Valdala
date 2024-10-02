module asset;

import std::io;
import std::compression::qoi;

fn DString! loadText(String path, Allocator allocator, usz expectedSize = 1024) {

    File file = file::open(path, "r")!;

    DString content;
    content.new_init(expectedSize, allocator);
    content.read_from_stream(&file)!;

    return content;
}

enum ColorSpace {
    SRGB,
    LINEAR
}

enum ColorChannels {
    RGB,
    RGBA
}

struct Image {
    Allocator allocator;
    char[] pixels;
    uint width;
    uint height;
    ColorSpace colorSpace;
    ColorChannels colorChannels;
}

fn void! Image.loadQOI(&self, String path, Allocator allocator) {

    self.allocator = allocator;

    QOIDesc description;
    char[] pixels = qoi::read(path, &description, AUTO, allocator)!;

    self.pixels = pixels;
    self.width = description.width;
    self.height = description.height;
    self.colorSpace = (ColorSpace) description.colorspace.id;
    self.colorChannels = (ColorChannels) description.channels.id - 3;
}

fn void Image.free(&self) {
    allocator::free(self.allocator, self.pixels);
}
