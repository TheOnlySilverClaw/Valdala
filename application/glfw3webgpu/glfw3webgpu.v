module glfw3webgpu

import glfw
import webgpu

#flag -I include
#flag -l glfw3webgpu
#include "glfw3webgpu.h"

fn C.glfwGetWGPUSurface(instance webgpu.WGPUInstance, window glfw.Window) webgpu.WGPUSurface

pub fn get_surface(instance webgpu.WGPUInstance, window glfw.Window) webgpu.WGPUSurface {
	return C.glfwGetWGPUSurface(instance, window)
}