module main

import glfw
import webgpu

fn main() {

	window := glfw.open_window(1200, 1000, "YAMC")!
	_ = window
	defer { glfw.terminate() }

	// for !window.should_close() {
	// 	window.swap_buffers()
	// 	glfw.poll_events()
	// }

	instance := webgpu.create_instance()!
	defer {instance.release()}

	adapter := instance.request_adapter() or {
		println("failed to request adapter")
		return
	}
	
	defer {adapter.release()}
}
