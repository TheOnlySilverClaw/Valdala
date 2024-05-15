module webgpu

import glfw
import webgpu.binding

#flag -l glfw3webgpu
#include "glfw3webgpu.h"

fn C.glfwGetWGPUSurface(instance binding.WGPUInstance, window glfw.Window) binding.WGPUSurface

pub fn (instance Instance) get_surface(window glfw.Window) Surface {
	surface := C.glfwGetWGPUSurface(instance.ptr, window)
	return Surface{
		ptr: surface
	}
}
