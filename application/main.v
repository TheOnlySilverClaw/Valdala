module main

import log

import graphics

#flag -L libraries
#flag -I include

#flag -l c
#flag -l m
#flag -l glfw
#flag -l wgpu_native
#flag -l glfw3webgpu

fn main() {

	graphics.create_renderer()!

	log.info("done")
}