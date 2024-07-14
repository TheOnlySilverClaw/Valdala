module graphics

import glfw3_webgpu
import webgpu
import glfw

pub struct Window {
	resize_listener	?ResizeListener
pub:
	ptr glfw.Window
	instance webgpu.Instance
	surface webgpu.Surface
	adapter webgpu.Adapter
	device webgpu.Device
pub mut:
	width u32
	height u32
	aspect_ratio f32
	depth_texture webgpu.Texture
}

pub type ResizeListener = fn (width u32, height u32)

@[param]
pub struct WindowOptions {
	title string
	width u32 @[required]
	height u32 @[required]
	resize_listener ?ResizeListener
}

pub fn Window.new(instance webgpu.Instance, options WindowOptions) !&Window {

	C.glfwWindowHint(C.GLFW_CLIENT_API, C.GLFW_NO_API)

	glfw_window := glfw.Window.new(
		width: options.width,
		height: options.height,
		title: options.title
		) or {
		return error("failed to create GLFW window")
	}

	surface := glfw3_webgpu.get_surface(instance, glfw_window)
	adapter := instance.request_adapter(surface) or { return error('adapter error') }
	device := adapter.request_device() or { return error('device error') }

	surface.configure(adapter, device, options.width, options.height)

	depth_texture := create_depth_texture(device, options.width, options.height)

	mut window := &Window {
		ptr: glfw_window
		width: options.width
		height: options.height
		aspect_ratio: f32(options.width) / f32(options.height)
		resize_listener: options.resize_listener
		instance: instance
		surface: surface
		adapter: adapter
		device: device
		depth_texture: depth_texture
	}

	glfw_window.on_resize(fn[mut window](width int, height int) {
		window.set_size(u32(width), u32(height))
	})

	return window
}

pub fn (mut window Window) set_size(width u32, height u32) {

	window.width = width
	window.height = height
	window.aspect_ratio = f32(width) / f32(height)

	window.surface.configure(window.adapter, window.device, width, height)

	window.depth_texture.release()
	window.depth_texture = create_depth_texture(window.device, width, height)
	
	if notify := window.resize_listener {
		notify(width, height)
	}
}

fn create_depth_texture(device webgpu.Device, width u32, height u32) webgpu.Texture {
	return device.create_texture(
		label: 'depth'
		width: u32(width)
		height: u32(height)
		format: .depth24_plus
		usage: .render_attachment
	)
}

pub fn (window Window) should_close() bool {
	return C.glfwWindowShouldClose(window.ptr) == C.GLFW_TRUE
}

pub fn (window Window) update() {
}

pub fn (window Window) destroy() {
	C.glfwDestroyWindow(window.ptr)
	window.surface.release()
	window.adapter.release()
	window.device.release()
}

pub fn (window Window) view_matrix() []f32 {
	return projection(100, window.aspect_ratio, 1000.0)
}