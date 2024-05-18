module graphics

import log
import time
import glfw
import webgpu

struct Renderer {
	device         webgpu.Device
	surface        webgpu.Surface
	queue          webgpu.Queue
	texture_format webgpu.TextureFormat
	shader_module  webgpu.ShaderModule
	bind_group     webgpu.BindGroup
	vertex_buffer  webgpu.Buffer
	pipeline       webgpu.RenderPipeline
}

pub fn create_renderer() ! {
	log.info('launch')

	instance := webgpu.create_instance()!
	defer {
		instance.release()
	}
	log.info('created instance')

	window := glfw.open_window(1200, 1000, 'Vandala')!
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

	shader_module := device.create_shader('shaders/colored.wgsl', 'colored') or {
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

	window.on_resize(fn [surface, adapter, device] (width int, height int) {
		surface.configure(adapter, device, u32(width), u32(height))
	})

	log.info('surface configured')

	texture_format := surface.get_preferred_format(adapter)
	log.info('preferred texture format: ${texture_format}')

	bindgroup_layout := device.create_bindgroup_layout()
	defer {
		bindgroup_layout.release()
	}
	log.info('created bindgroup layout')

	pipeline_layout := device.create_pipeline_layout(bindgroup_layout)

	render_pipeline := device.create_render_pipeline('colored', pipeline_layout, shader_module,
		shader_module, texture_format)
	defer {
		render_pipeline.release()
	}
	log.info('created render pipeline')

	size := f32(0.5)
	// vfmt off
	vertex_data := [
		// x	y			color	opacity
		-size, size,		1, 0, 0, 1,
		-size, 0,			0, 1, 0, 1,
		0, 0,				0, 0, 1, 1,

		-size, size,		1, 0, 0, 1,
		0, 0,				1, 0, 0, 1,
		0, size,			1, 0, 0, 1,
	]

	vertex_buffer := device.create_buffer('vertices', u32(vertex_data.len) * sizeof(f32))
	defer {
		vertex_buffer.destroy()
	}
	log.info('created vertex buffer of size ${vertex_buffer.size}')
	queue.write_buffer(vertex_buffer, 0, vertex_data)
	vertex_buffer.unmap()

	bind_group := device.create_bindgroup('colored', bindgroup_layout, vertex_buffer)
	defer {
		bind_group.release()
	}
	log.info('created bindgroup')

	mut renderer := Renderer{
		device: device
		surface: surface
		queue: queue
		shader_module: shader_module
		texture_format: texture_format
		vertex_buffer: vertex_buffer
		bind_group: bind_group
		pipeline: render_pipeline
	}

	for !window.should_close() {
		
		glfw.poll_events()

		renderer.render()!

		// window.swap_buffers()

		time.sleep(1 * time.millisecond)
	}
}

fn (renderer Renderer) render() ! {
	surface_texture := renderer.surface.get_current_texture()!
	defer {
		surface_texture.release()
	}
	log.debug('got current surface texture')

	frame := surface_texture.get_view()
	defer {
		frame.release()
	}
	log.debug('got current frame texture')

	command_encoder := renderer.device.create_command_encoder('encoder')
	defer {
		command_encoder.release()
	}
	log.debug('command encoder created')

	render_pass_encoder := command_encoder.begin_render_pass(frame)
	defer {
		render_pass_encoder.release()
	}
	log.debug('pass encoder created')

	render_pass_encoder.set_pipeline(renderer.pipeline)
	render_pass_encoder.set_bindgroup(0, renderer.bind_group)
	render_pass_encoder.set_vertex_buffer(0, renderer.vertex_buffer, 0)
	render_pass_encoder.draw(6, 1, 0, 0)

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
