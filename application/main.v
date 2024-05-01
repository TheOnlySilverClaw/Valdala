module main

import glfw

fn main() {

	window := glfw.open_window(1200, 1000, "YAMC")!
	defer { glfw.terminate() }

	for !window.should_close() {
		window.swap_buffers()
		glfw.poll_events()
	}

}
