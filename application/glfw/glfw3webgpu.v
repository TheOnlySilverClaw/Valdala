module glfw

import webgpu

#flag -l glfw3webgpu
#include "glfw3webgpu.h"

fn C.glfwGetWGPUSurface(instance webgpu.WGPUInstance, window glfw.Window) webgpu.WGPUSurface

pub fn (window glfw.Window) get_surface(instance webgpu.WGPUInstance) webgpu.WGPUSurface {
	return C.glfwGetWGPUSurface(instance, window)
}