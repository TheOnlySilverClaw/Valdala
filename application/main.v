module main

import glfw
import webgpu

fn main() {

	println("launch")
	
	instance := webgpu.create_instance()!
	defer {instance.release()}
	println("created instance")

	window := glfw.open_window(1200, 1000, "YAMC")!
	defer { glfw.terminate() }
	defer { window.destroy() }
	println("created window")

	surface := window.get_surface(instance)
	defer { surface.release() }
	println("created surface")

	adapter := instance.request_adapter(surface) or {
		println("failed to get adapter")
		return
	}
	defer { adapter.release() }
	println("created adapter")

	device := adapter.request_device() or {
		println("failed to get device")
		return
	}
	defer { device.release() }
	println("created device")

	queue := device.get_queue()
	defer { queue.release() }
	println("created queue")

	surface.configure(adapter, device)
	println("surface configured")

	for !window.should_close() {

		render(device, surface, queue)!

		window.swap_buffers()
		glfw.poll_events()
	}

	println("done")
}

fn render(device webgpu.WGPUDevice, surface webgpu.WGPUSurface, queue webgpu.WGPUQueue) ! {

	surface_texture := surface.get_current_texture()!
	defer { surface_texture.release() }
	println("got current surface texture")

	frame := surface_texture.get_view(1)
	defer { frame.release() }
	println(frame)

	command_encoder := device.create_command_encoder("encoder")
	defer { command_encoder.release() }
	println("command encoder created")

	render_pass_encoder := command_encoder.begin_render_pass(frame)
	defer { render_pass_encoder.release() }
	render_pass_encoder.end()
	println("pass encoder created")

	command_buffer := command_encoder.finish()
	defer { command_buffer.release() }
	println("command buffer created")

	queue.submit(&command_buffer)
	println("command submitted")

	surface.present()
}
