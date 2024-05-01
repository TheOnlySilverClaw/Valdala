module main

#flag -I include
#flag -L libraries

#flag -l c
#flag -l m
#flag -l unwind
#flag -l glfw
#flag -l wgpu_native

#include "glfw3.h"
#include "wgpu.h"

fn C.glfwInit() int

fn C.wgpuGetVersion() int

fn main() {
	major, minor := C.GLFW_VERSION_MAJOR, C.GLFW_VERSION_MINOR
	C.glfwInit()
	println('Hello glfw v${major}.${minor}!')
	wgpu := C.wgpuGetVersion()
	println("wgpu version: ${wgpu}")
}
