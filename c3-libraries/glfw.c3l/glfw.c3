module glfw;

fault GlfwError {
    INITIALIZE
}

fn void! initialize() {

    if(init() != TRUE) {
        return GlfwError.INITIALIZE?;
    }
}
