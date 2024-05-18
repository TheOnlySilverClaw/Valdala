module graphics

import log
import time
import glfw
import webgpu
import henrixounez.vpng

struct Renderer {
	device          webgpu.Device
	surface         webgpu.Surface
	queue           webgpu.Queue
	texture_format  webgpu.TextureFormat
	shader_module   webgpu.ShaderModule
	bind_group      webgpu.BindGroup
	vertex_buffer   webgpu.Buffer
	pipeline        webgpu.RenderPipeline
	mesh_size       u32
	color_texture   webgpu.Texture
	texture_sampler webgpu.Sampler
mut:
	depth_texture webgpu.Texture
}

pub fn create_renderer() ! {
	log.info('launch')

	instance := webgpu.create_instance()!
	defer {
		instance.release()
	}
	log.info('created instance')

	window := glfw.open_window(1200, 1000, 'Valdala')!
	defer {
		glfw.terminate()
	}
	defer {
		window.destroy()
	}
	log.info('created window')

	surface := instance.get_surface(window)
	defer {
		surface.release()
	}
	log.info('created surface')

	adapter := instance.request_adapter(surface) or {
		log.info('failed to get adapter')
		return
	}
	defer {
		adapter.release()
	}
	log.info('created adapter')

	device := adapter.request_device() or {
		log.info('failed to get device')
		return
	}
	defer {
		device.release()
	}
	log.info('created device')

	shader_module := device.create_shader('shaders/textured.wgsl', 'textured') or {
		return error('failed to load shader_module')
	}
	defer {
		shader_module.release()
	}
	log.info('shader_module loaded')

	queue := device.get_queue()
	defer {
		queue.release()
	}
	log.info('created queue')

	surface.configure(adapter, device, 1200, 1000)

	log.info('surface configured')

	texture_format := surface.get_preferred_format(adapter)
	log.info('preferred texture format: ${texture_format}')

	depth_texture := device.create_texture(
		label: 'depth'
		width: 1200
		height: 1000
		format: .depth24plus
		usage: .render_attachment
	)
	log.info('created depth texture')

	bindgroup_layout := device.create_bindgroup_layout()
	defer {
		bindgroup_layout.release()
	}
	log.info('created bindgroup layout')

	pipeline_layout := device.create_pipeline_layout(bindgroup_layout)

	render_pipeline := device.create_render_pipeline('textured', pipeline_layout, shader_module,
		shader_module, texture_format)
	defer {
		render_pipeline.release()
	}
	log.info('created render pipeline')

	texture_image := vpng.read('textures/terrain/water.png')!
	mut pixels := []u8{cap: texture_image.pixels.len * 4}

	for pixel in texture_image.pixels {
		match pixel {
			vpng.TrueColor {
				pixels << pixel.red
				pixels << pixel.green
				pixels << pixel.blue
				pixels << 255
			}
			vpng.TrueColorAlpha {
				pixels << pixel.red
				pixels << pixel.green
				pixels << pixel.blue
				pixels << pixel.alpha
			}
			else {
				log.error('unsupported pixel type: ${pixel}')
			}
		}
	}

	texture_width := u32(texture_image.width)
	texture_height := u32(texture_image.height)

	log.info('loaded texture with ${pixels.len / 4} (${texture_width} * ${texture_height}) pixels')

	color_texture := device.create_texture(
		label: 'test_texture'
		width: texture_width
		height: texture_height
		usage: .texture_binding | .copy_dst
		format: .rgba8unorm
	)

	queue.write_texture(color_texture, pixels,
		width: texture_width
		height: texture_height
		// TODO calculate from image
		layout: webgpu.TextureDataLayout{
			bytesPerRow: 4 * texture_width
			rowsPerImage: texture_height
		}
	)

	texture_view := color_texture.get_view()
	defer {
		texture_view.release()
	}

	sampler := device.create_sampler()
	defer {
		sampler.release()
	}

	size := f32(0.5)
	// vfmt off
	vertex_data := [
		// x	y			u  v  texture index
		-size,	size		0, 0, 0,
		-size, -size,		0, 1, 0,
		size, -size,		1, 1, 0,

		size, -size,		1, 1, 0,
		size, size,			1, 0, 0,
		-size, size,		0, 0, 0,
	]
	// vfmt on

	vertex_buffer := device.create_buffer('vertices', u32(vertex_data.len) * sizeof(f32))
	defer {
		vertex_buffer.destroy()
	}
	log.info('created vertex buffer of size ${vertex_buffer.size}')
	queue.write_buffer(vertex_buffer, 0, vertex_data)

	bind_group := device.create_bindgroup('textured', bindgroup_layout, vertex_buffer,
		sampler, texture_view)
	defer {
		bind_group.release()
	}
	log.info('created bindgroup')

	mut renderer := &Renderer{
		device: device
		surface: surface
		queue: queue
		shader_module: shader_module
		texture_format: texture_format
		vertex_buffer: vertex_buffer
		bind_group: bind_group
		pipeline: render_pipeline
		depth_texture: depth_texture
		mesh_size: u32(vertex_data.len) / (2 + 2 + 1)
	}

	window.on_resize(fn [mut renderer, adapter] (width int, height int) {
		renderer.surface.configure(adapter, renderer.device, u32(width), u32(height))
		renderer.depth_texture.release()
		log.debug('create resized depth texture')
		renderer.depth_texture = renderer.device.create_texture(
			label: 'depth'
			width: u32(width)
			height: u32(height)
			format: .depth24plus
			usage: .render_attachment
		)
	})

	for !window.should_close() {
		glfw.poll_events()

		renderer.render()!

		// window.swap_buffers()

		time.sleep(1 * time.millisecond)
	}
}

fn (renderer &Renderer) render() ! {
	surface_texture := renderer.surface.get_current_texture()!
	defer {
		surface_texture.release()
	}
	log.debug('got current surface texture')

	frame := surface_texture.get_view()
	defer {
		frame.release()
	}
	log.debug('got current frame texture view')

	depth_frame := renderer.depth_texture.get_view(aspect: .depth_only)
	defer {
		depth_frame.release()
	}
	log.debug('got current depth texture view')

	command_encoder := renderer.device.create_command_encoder('encoder')
	defer {
		command_encoder.release()
	}
	log.debug('command encoder created')

	render_pass_encoder := command_encoder.begin_render_pass(frame, depth_frame)
	defer {
		render_pass_encoder.release()
	}
	log.debug('pass encoder created')

	render_pass_encoder.set_pipeline(renderer.pipeline)
	render_pass_encoder.set_bindgroup(0, renderer.bind_group)
	render_pass_encoder.set_vertex_buffer(0, renderer.vertex_buffer, 0)
	render_pass_encoder.draw(renderer.mesh_size, 1, 0, 0)

	render_pass_encoder.end()
	log.debug('render pass ended')

	command_buffer := command_encoder.finish()
	defer {
		command_buffer.release()
	}
	log.debug('command buffer created')

	renderer.queue.submit(command_buffer)
	log.debug('command submitted')

	renderer.surface.present()
}
