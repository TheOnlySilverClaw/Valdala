module main

import glfw
import webgpu
import glfw3webgpu

fn main() {

	println("launch")
	
	instance := webgpu.create_instance()!
	defer {instance.release()}
	println("created instance")

	window := glfw.open_window(1200, 1000, "YAMC")!
	defer { glfw.terminate() }
	defer { window.destroy() }
	println("created window")

	surface := glfw3webgpu.get_surface(instance, window)
	defer { surface.release() }
	println("created surface")

	adapter := instance.request_adapter(surface) or {
		println("failed to request adapter")
		return
	}
	defer { adapter.release() }
	println("created adapter")

	for !window.should_close() {
		window.swap_buffers()
		glfw.poll_events()
	}

	println("done")
}
