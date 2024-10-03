module asset;

import std::io;
import std::compression::qoi;

fault AssetError { UNSUPPORTED_FORMAT }

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

enum ColorChannels: (char size) {
    RGB = 3,
    RGBA = 4
}

struct Image {
    Allocator allocator;
    char[] pixels;
    uint width;
    uint height;
    ColorSpace colorSpace;
    ColorChannels colorChannels;
}


fn void! Image.load(&self, Path path, Allocator allocator) {
    
    String extension = path.extension()!;

    switch(extension) {
        case "qoi": self.loadQOI(path, allocator)!;
        default: return AssetError.UNSUPPORTED_FORMAT?;
    }
}


fn void! Image.loadQOI(&self, Path path, Allocator allocator) {

    self.allocator = allocator;

    QOIDesc description;
    char[] pixels = qoi::read(path.str_view(), &description, AUTO, allocator)!;

    self.pixels = pixels;
    self.width = description.width;
    self.height = description.height;
    self.colorSpace = (ColorSpace) description.colorspace.id;
    self.colorChannels = (ColorChannels) description.channels.id - 3;
}

fn void Image.free(&self) {
    allocator::free(self.allocator, self.pixels);
}
