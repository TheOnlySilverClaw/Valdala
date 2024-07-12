module asset

import webgpu
import henrixounez.vpng

const rgba_width = u32(4)

pub fn load_texture_png(path string, device webgpu.Device, queue webgpu.Queue) !webgpu.Texture {

	image := vpng.read(path)!

	width := u32(image.width)
	height := u32(image.height)
	pixels := image.pixels

	mut rgba := []u8{cap: pixels.len * rgba_width}

	for pixel in pixels {
		match pixel {
			vpng.TrueColor {
				rgba << pixel.red
				rgba << pixel.green
				rgba << pixel.blue
				rgba << 255
			}
			vpng.TrueColorAlpha {
				rgba << pixel.red
				rgba << pixel.green
				rgba << pixel.blue
				rgba << pixel.alpha
			}
			else {
				error('unsupported pixel type: ${pixel}')
			}
		}
	}

	texture := device.create_texture(
		width: width
		height: height
		usage: .texture_binding | .copy_dst
		format: .rgba8_unorm
	)

	queue.write_texture(texture, rgba,
		width: width
		height: height
		layout: webgpu.TextureDataLayout {
			bytesPerRow: width * rgba_width
			rowsPerImage: height
		}
	)

	return texture
}