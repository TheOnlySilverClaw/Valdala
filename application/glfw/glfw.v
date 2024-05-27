module glfw

#flag -I include
#flag -l glfw
#include "glfw3.h"

fn C.glfwInit() int

fn C.glfwWindowHint(hint int value int)

fn C.glfwCreateWindow(width int, height int, name &char, monitor voidptr, sharedWindow voidptr) Window

fn C.glfwWindowShouldClose(window Window) int

fn C.glfwDestroyWindow(window Window)

fn C.glfwSwapBuffers(window Window)

fn C.glfwPollEvents()

fn C.glfwTerminate()

fn C.glfwSetFramebufferSizeCallback(window Window, callback FramebufferSizeCallback)

type FramebufferSizeCallback = fn(window Window, width int, height int)