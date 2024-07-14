module graphics

import log
import time
import os
import webgpu
import asset
import glfw

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
	projection_buffer webgpu.Buffer
}

pub fn create_renderer() ! {
	log.info('launch')

	instance := webgpu.create_instance()!
	defer { instance.release() }
	log.info('created instance')

	if !glfw.initialize() {
		return error('GLFW could not be initialized!')
	}
	defer { glfw.terminate() }

	window := Window.new(instance, width: 1200, height: 1000, title: 'Valdala')!

	defer { window.destroy()}
	log.info('created window')

	shader_source := os.read_file('shaders/textured.wgsl') or {
		return error('failed to load shader')
	}

	shader_module := window.device.create_shader(shader_source, 'textured') or {
		return error('failed to load shader_module')
	}
	defer { shader_module.release() }
	log.info('shader_module loaded')

	queue := window.device.get_queue()
	defer { queue.release() }
	log.info('created queue')

	texture_format := window.surface.get_preferred_format(window.adapter)
	log.info('preferred texture format: ${texture_format}')

	bindgroup_layout := window.device.create_bindgroup_layout()
	defer { bindgroup_layout.release() }
	log.info('created bindgroup layout')

	pipeline_layout := window.device.create_pipeline_layout(bindgroup_layout)

	render_pipeline := window.device.create_render_pipeline('textured', pipeline_layout,
		shader_module, shader_module, texture_format)
	defer { render_pipeline.release() }
	log.info('created render pipeline')

	color_texture := asset.load_texture_png(
		'textures/testing/texture_1.png', window.device, queue)!
	defer { color_texture.release() }
	log.info('loaded color texture ${color_texture}')

	texture_view := color_texture.get_view()
	defer { texture_view.release() }

	sampler := window.device.create_sampler()
	defer { sampler.release() }

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

	vertex_buffer := window.device.create_buffer(
		label: 'vertices'
		size: u32(vertex_data.len) * sizeof(f32)
		usage: .vertex | .copy_dst
	)
	defer { vertex_buffer.destroy() }
	log.info('created vertex buffer of size ${vertex_buffer.size}')
	queue.write_buffer(vertex_buffer, 0, vertex_data)

	projection_buffer := window.device.create_buffer(
		label: 'projection'
		size: 4 * 4 * sizeof(f32)
		usage: .uniform | .copy_dst
	)
	defer { projection_buffer.destroy() }

	bind_group := window.device.create_bindgroup('textured', bindgroup_layout, projection_buffer,
		sampler, texture_view)
	defer { bind_group.release() }
	log.info('created bindgroup')

	mut renderer := &Renderer{
		device: window.device
		surface: window.surface
		queue: queue
		shader_module: shader_module
		texture_format: texture_format
		vertex_buffer: vertex_buffer
		bind_group: bind_group
		pipeline: render_pipeline
		mesh_size: u32(vertex_data.len) / (2 + 2 + 1)
		projection_buffer: projection_buffer
	}

	for !window.should_close() {

		glfw.poll_events()

		renderer.render(window)!

		time.sleep(1 * time.millisecond)
	}
}

fn (renderer &Renderer) render(window &Window) ! {

	projection := window.view_matrix()
	renderer.queue.write_buffer(renderer.projection_buffer, 0, projection)

	surface_texture := renderer.surface.get_current_texture()!
	defer { surface_texture.release() }
	log.debug('got current surface texture')

	frame := surface_texture.get_view()
	defer { frame.release() }
	log.debug('got current frame texture view')

	depth_frame := window.depth_texture.get_view(aspect: .depth_only)
	defer { depth_frame.release() }
	log.debug('got current depth texture view')

	command_encoder := renderer.device.create_command_encoder('encoder')
	defer { command_encoder.release() }
	log.debug('command encoder created')

	render_pass_encoder := command_encoder.begin_render_pass(frame, depth_frame)
	defer { render_pass_encoder.release() }
	log.debug('pass encoder created')

	render_pass_encoder.set_pipeline(renderer.pipeline)
	render_pass_encoder.set_bindgroup(0, renderer.bind_group)
	render_pass_encoder.set_vertex_buffer(0, renderer.vertex_buffer, 0)
	render_pass_encoder.draw(renderer.mesh_size, 1, 0, 0)

	render_pass_encoder.end()
	log.debug('render pass ended')

	command_buffer := command_encoder.finish()
	defer { command_buffer.release() }
	log.debug('command buffer created')

	renderer.queue.submit(command_buffer)
	log.debug('command submitted')

	renderer.surface.present()
}
