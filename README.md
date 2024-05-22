# Current state

Not much to look at, yet.
But the WebGPU bindings are working!

After working around color space issues, textures look as intended.

![Screenshot of current development state](screenshot.png)


# Setup

## V

The 0.4.6 version of [V](https://vlang.io/) is used to compile the project.
Currently commit [1b5af1f](https://github.com/vlang/v/commit/1b5af1f9894d9619888c6e4875111d78555d92ca) is required for formatting.

## Compiler

V uses Tiny C Compiler (tcc) for development builds by default.
Unfortunately, tcc fails to compile the WebGPU headers.

Therefore, the build commands set [Clang](https://clang.llvm.org/) as the C compiler.


## Tools

Checking out the repository and submodules obviously requires [git](https://git-scm.com/).

Building wgpu-native requires a [Rust](https://www.rust-lang.org/) compiler and [make](https://www.gnu.org/software/make/).


## Dependencies

These dependencies are used to make windowing and graphics work:

| Name | Purpose | Installation |
| -- | -- | -- |
| [GLFW 3](https://www.glfw.org/)| window and input handling | system |
| [glfw3webgpu](https://github.com/eliemichel/glfw3webgpu)| create WebGPU surface from GLFW window | precompiled |
| [wgpu-native](https://github.com/gfx-rs/wgpu-native)| run WebGPU over system dependent graphics API | submodule |


## Tasks

[Task](https://taskfile.dev/) is used to run repetitive commands.
It's not required, but makes development easier.

Set up git submodules and compile required libraries:
```
task setup
```

Build and immediately launch the application:
```
task run
```

List other tasks:
```
task --list-all
```