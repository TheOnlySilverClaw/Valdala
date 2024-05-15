module graphics

import log
import time

import glfw
import webgpu

struct Renderer {
	device webgpu.Device
	surface webgpu.Surface
	queue webgpu.Queue
	texture_format webgpu.TextureFormat
	shader_module webgpu.ShaderModule
}

pub fn create_renderer()! {

	log.info("launch")
	
	instance := webgpu.create_instance()!
	defer {instance.release()}
	log.info("created instance")

	window := glfw.open_window(1200, 1000, "Vandala")!
	defer { glfw.terminate() }
	defer { window.destroy() }
	log.info("created window")

	surface := instance.get_surface(window)
	defer { surface.release() }
	log.info("created surface")

	adapter := instance.request_adapter(surface) or {
		log.info("failed to get adapter")
		return
	}
	defer { adapter.release() }
	log.info("created adapter")

	device := adapter.request_device() or {
		log.info("failed to get device")
		return
	}
	defer { device.release() }
	log.info("created device")

	shader_module := device.create_shader("shaders/colored.wgsl", "colored") or {
		return error("failed to load shader_module")
	}
	defer { shader_module.release() }
	log.info("shader_module loaded")

	queue := device.get_queue()
	defer { queue.release() }
	log.info("created queue")

	surface.configure(adapter, device, 1200, 1000)

	window.on_resize(fn[surface, adapter, device](width int, height int) {
		surface.configure(adapter, device, u32(width), u32(height))
	})

	log.info("surface configured")

	texture_format := surface.get_preferred_format(adapter)
	log.info("preferred texture format: $texture_format")

	mut renderer := Renderer {
		device: device,
		surface: surface,
		queue: queue,
		shader_module: shader_module,
		texture_format: texture_format
	}

	bindgroup_layout := device.create_bindgroup_layout()
	defer { bindgroup_layout.release() }
	log.info("created bindgroup layout")

	pipeline_layout := device.create_pipeline_layout(bindgroup_layout)

	device.create_render_pipeline("colored", pipeline_layout, shader_module, shader_module)

	for !window.should_close() {

		renderer.render()!

		window.swap_buffers()
		glfw.poll_events()

		time.sleep(1 * time.millisecond)
	}
}

fn (renderer Renderer) render() ! {

	surface_texture := renderer.surface.get_current_texture()!
	defer { surface_texture.release() }
	log.debug("got current surface texture")

	frame := surface_texture.get_view(1)
	defer { frame.release() }
	log.debug("got current frame texture")

	command_encoder := renderer.device.create_command_encoder("encoder")
	defer { command_encoder.release() }
	log.debug("command encoder created")

	render_pass_encoder := command_encoder.begin_render_pass(frame)
	defer { render_pass_encoder.release() }
	render_pass_encoder.end()
	log.debug("pass encoder created")

	command_buffer := command_encoder.finish()
	defer { command_buffer.release() }
	log.debug("command buffer created")

	renderer.queue.submit(command_buffer)
	log.debug("command submitted")

	renderer.surface.present()
}
