module graphics;

import std::io::path;
import std::io;

import webgpu;
import asset;

fault TextureLoadingFault {
    UNSUPPORTED_FORMAT
} 

struct TextureLoader {
    Path root;
    Device device;
    Queue queue;
}

fn Texture! TextureLoader.loadTextureArray(&self, TextureFormat format, uint width, uint height, String... files) {

    TextureDescriptor descriptor = {
        .label = "texture_array",
        .usage = {
            .textureBinding = true,
            .copyDestination = true
        },
        .dimension = DIMENSION_2D,
        .size = {
            .width = width,
            .height = height,
            .depthOrArrayLayers = files.len
        },
        .format = format,
        .mipLevelCount = 1,
        .sampleCount = 1
    };


    Texture texture = self.device.createTexture(&descriptor);

    foreach(uint layer, String file: files) {
        self.loadArrayTexture(texture, file, layer)!;
    }

    // TextureViewDescriptor viewDescriptor = {
	// 	.format = format,
	// 	.dimension = ARRAY_2D,
	// 	.baseMipLevel = 0,
	// 	.mipLevelCount = 1,
	// 	.baseArrayLayer = 0,
	// 	.arrayLayerCount = files.len,
	// 	.aspect = ALL
	// };
	
	// TextureView view = texture.createView(&viewDescriptor);

    return texture;
}

fn void! TextureLoader.loadArrayTexture(&self, Texture texture, String file, uint layer) @local {

    Path resolved = self.root.new_append(file)!;
    defer resolved.free();

    Image* image = Image{}.load(resolved)!;
    defer image.free();

    ImageCopyTexture destination = {
		.texture = texture,
		.mipLevel = 0,
		.origin = {
            .x = 0,
            .y = 0,
            .z = layer
        },
		.aspect = ALL
	};
	
	TextureDataLayout layout = {
		.offset = 0,
		.bytesPerRow = image.width * image.colorChannels.size,
		.rowsPerImage = image.height
	};
	
	Extent3D extent = { image.width, image.height, 1 };

	self.queue.writeTexture(&destination, image.pixels.ptr, image.pixels.len, &layout, &extent);
}