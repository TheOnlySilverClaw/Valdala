module glfw


fn initialize() bool {
	return C.glfwInit() == C.GLFW_TRUE
}

pub fn open_window(width int, height int, name string) !Window {

	if !initialize() {
		error("could not initialze GLFW")
	}

	C.glfwWindowHint(C.GLFW_CLIENT_API, C.GLFW_NO_API)
	
	window := C.glfwCreateWindow(width, height, &char(name.str), C.NULL, C.NULL)
	return window
}

pub fn (window Window) should_close() bool {
	return C.glfwWindowShouldClose(window) == C.GLFW_TRUE
}

pub fn (window Window) swap_buffers() {
	C.glfwSwapBuffers(window)
}

pub fn poll_events() {
	C.glfwPollEvents()
}

pub fn terminate() {
	C.glfwTerminate()
}