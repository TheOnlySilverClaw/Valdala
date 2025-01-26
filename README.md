Valdala is supposed to become a game... eventually.
Currently, it is primarly my excuse to tinker with technologies I'm interested in.


# Reason

Like most of my projects, the idea started with me being unhappy about something. In this case, Minecraft.
I liked building houses and towns, but after a construction project was finished, it was just... there... decoratively.
There's no practical real reason in Minecraft to build anything fancy.
A slightly bigger hole in the ground could contain everything you would need to survive the game.

Also, modding in Minecraft has so many unnecessary hoops to jump through, it's a miracle the community managed to do it.

That said, Valdala will not be: a Minecraft clone or a generic voxel renderer demo.

The goal is to create a solid base engine focused on performance, maintainability and extensibility from the ground up.
Something like [Luanti](https://www.luanti.org/), [Terasology](https://terasology.org/) or [Vintage Story](https://www.vintagestory.at/), just... my own.
And while I'm aware I could just be modding one of those... I don't wanna.

And on top of that, provide core plugins forming a coherent and distinct game experience.


# Idea

Valdala plays in a procedurally generated 3D world made of blocks.

You start with some basic survival gear and have to sustain yourself by gathering ressources.

You can craft basic tools and weapons and build basic shelter by yourself.

However, to get a stable source of food, more sophisticated equipment and solid housing, you need help of villagers.

Countless hostile creatures roam the world and most villagers are willing to work for you in exchange for protection.

You can guide your loyal villagers to develop their settlement, establish diplomatic ties with friendly neighbors and fight monsters and bandits to protect your towns and trade routes.


# Technology

I want to build Valdala on a foundation of high quality, future-proof technologies and as few external dependencies as reasonably possible.

Currently, the tech stack looks like this:

- [Zig](https://ziglang.org/) as the primary programming language for the engine
- a fast, modern, type-safe and expressive scripting language ([to be decided](https://codeberg.org/Silverclaw/Valdala/src/branch/development/notes.md#scripting))
- [WebGPU](https://www.w3.org/TR/webgpu/) via wgpu-native as a cross-platform graphics API
- [GLFW](https://www.glfw.org/) for cross-platform window management and input handling
- well supported open source file formats for everything, like [QOI](https://qoiformat.org/) for textures, [glTF](https://www.khronos.org/gltf/) for 3D assets, etc.


# Help Appreciated

Valdala is a passion project and I'm willing to spend countless hours trying to make it work on my own.

However, if anyone is willing to help out and learn a thing or two on the way, I'd appreaciate that.

Since this project does not generate revenue and probably never will, there's no promise of compensation beyond that.

Currently in demand:


## 3D Engine Developer

Let's build a fast and maintanable 3d rendering engine. Maybe even a pretty one!

Required skills:

- graphics programming in WebGPU, Vulkan, Metal, OpenGL or Direct3D
- 3D math, especially vectors, matrices and quaternions
- programming in a language with manual memory management, like Zig, C, C++, Rust, V, Nim or Odin
- using git and build tools


# Current State

This section is for showing update screenshots and holding myself accountable.

So many commits and so little to show?

The reason for that is mostly me trying out half a dozen programming languages (Rust, TypeScript, Go, C++, V, C3) before (fingers crossed!) settling on Zig.
At this point, I'm comfortable I can build anything I need with that and the language will be well maintained and going in a promising direction for the foreseeable future.
I also had to get used to low level programming and manual memory management, but I actually enjoy that now.

Even worse, I had to brush up my maths and nearly non-existent graphics programming experience and start from nothing with WebGPU while the standard is still settling.

Could I just use an engine instead? Sure, but where's the fun in that?

So, currently, there's a floating textured quad:

![screenshot](screenshot.png)