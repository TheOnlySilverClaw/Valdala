module glfw;

const TRUE = 1;

fault GlfwError {
    INITIALIZE
}

fn void! init() {

    if(glfwInit() != TRUE) {
        return GlfwError.INITIALIZE?;
    }
}

fn bool Window.shouldClose(Window window) {
    return glfwWindowShouldClose(window) == TRUE;
}
