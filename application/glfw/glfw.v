module glfw

#flag -I include
#flag -l glfw
#include "glfw3.h"

pub type Window = voidptr

fn C.glfwInit() int

fn C.glfwCreateWindow(width int, height int, name &char, monitor voidptr, sharedWindow voidptr) Window

fn C.glfwWindowShouldClose(window Window) int

fn C.glfwSwapBuffers(window Window)

fn C.glfwPollEvents()

fn C.glfwTerminate()