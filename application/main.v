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

	for !window.should_close() {
		window.swap_buffers()
		glfw.poll_events()
	}

	println("done")
}
