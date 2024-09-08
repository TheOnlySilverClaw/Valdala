module demo;
import std::io;
import glfw;

fn void! main(String[] args) {
	

	glfw::setErrorCallback(fn(ErrorCode code, ZString description) {
		if(code == error::NOT_INITIALIZED) {
			io::printn("Someone forgot to initialize GLFW!");
		} else {
			io::printfn("GLFW error: %s %s", code, description);
		}
	});

	// generates above error on purpose
	glfw::pollEvents();

	glfw::initialize()!;
	defer glfw::terminate();

	listMonitors();

	Monitor monitor = monitor::getPrimaryMonitor();
	VideoMode* mode = monitor.getVideoMode();

	Window window = glfw::window::create(mode.width / 2, mode.height / 2, "GLFW Demo");
	defer window.destroy();

	setupKeyCallback(window);

	while(!window.shouldClose()) {
		glfw::pollEvents();
	}
}


fn void setupKeyCallback(Window window) {

	window.setKeyCallback(fn(Window window, Key key, Scancode scancode, Action action, Modifiers modifiers) {

		ZString name = keyboard::getKeyName(key, scancode);
		if(name == null) {
			io::printfn("key %s %d (%d)", action, key, scancode);
		} else {
			io::printfn("key %s %d \"%s\" (%d)", action, key, name, scancode);
		}
		io::printfn("modifiers: SHIFT %s CTRL %s ALT %s",
			modifiers.shift, modifiers.control, modifiers.alt);

		if(action == RELEASE && modifiers.control) {
			switch(key) {
			case key::I: {
				io::printn("iconify window");
				window.iconify();
			}
			case key::T: {
				io::printfn("set window transparent");
				window.setOpacity(0.4);
			}
			case key::O: {
				io::printfn("set window opaque");
				window.setOpacity(1.0);
			}
			case key::M: {
				io::printn("maximize window");
				window.maximize();
			}
			case key::Q: {
				io::printn("closing window");
				window.setShouldClose(glfw::TRUE);
			}
			}
		}
	});
}

fn void listMonitors() {


	int monitorCount;
	Monitor* monitors = monitor::getMonitors(&monitorCount);
	
	io::printf("\n%d monitors found\n\n", monitorCount);

	for(int i = 0; i < monitorCount; i++) {
		printMonitor(monitors[i]);
		io::printn();
	}
}

fn void printMonitor(Monitor monitor) {

	io::printfn("Name:\t\t%s", monitor.getName());
	
	int posX, posY;
	monitor.getPosition(&posX, &posY);
	io::printfn("Position:\t(%d,%d)", posX, posY);

	int waX, waY, waWidth, waHeight;
	monitor.getWorkarea(&waX, &waY, &waWidth, &waHeight);
	io::printfn("Workarea:\t(%d,%d)  %d px * %d px", waX, waY, waWidth, waHeight);

	int physWidth, physHeight;
	monitor.getPhysicalSize(&physWidth, &physHeight);
	io::printfn("Physical size:\t%d mm * %d mm", physWidth, physHeight);

	float csX, csY;
	monitor.getContentScale(&csX, &csY);
	io::printfn("Content scale:\t%d * %d", csX, csY);

	VideoMode* mode = monitor.getVideoMode();
	io::printfn("Video mode:\t%d px * %d px refresh rate: %d", mode.width, mode.height, mode.refreshRate);

	int modeCount;
	monitor.getVideoModes(&modeCount);
	io::printfn("%d video modes available", modeCount);

}
