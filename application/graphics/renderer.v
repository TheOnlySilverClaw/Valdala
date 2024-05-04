module graphics

import log

import glfw
import webgpu

struct Renderer {
	device webgpu.WGPUDevice
	surface webgpu.WGPUSurface
	queue webgpu.WGPUQueue
}

pub fn create_renderer()! {

	log.info("launch")
	
	instance := webgpu.create_instance()!
	defer {instance.release()}
	log.info("created instance")

	window := glfw.open_window(1200, 1000, "YAMC")!
	defer { glfw.terminate() }
	defer { window.destroy() }
	log.info("created window")

	surface := window.get_surface(instance)
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

	queue := device.get_queue()
	defer { queue.release() }
	log.info("created queue")

	surface.configure(adapter, device, 1200, 1000)
	log.info("surface configured")

	renderer := Renderer {
		device: device,
		surface: surface,
		queue: queue
	}

	for !window.should_close() {

		renderer.render()!

		window.swap_buffers()
		glfw.poll_events()
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

	renderer.queue.submit(&command_buffer)
	log.debug("command submitted")

	renderer.surface.present()
}
