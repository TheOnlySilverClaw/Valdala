# Development notes

## Ressources

[WebGPU Specification](https://www.w3.org/TR/webgpu/)

[Learn WebGPU C++ Guide](https://eliemichel.github.io/LearnWebGPU/index.html) by Elie Michel

[WebGPU Samples](https://webgpu.github.io/webgpu-samples/)

[Learn OpenGL](https://learnopengl.com/) by Joey de Vries

[WebGPU Headers](https://github.com/webgpu-native/webgpu-headers/blob/main/webgpu.h)

[Carmen's Graphics Blog](https://carmencincotti.com/posts/categories/webgpu/)


## Coordinate System

From the WebGPU C++ guide:

> - in.position is the local coordinates, or model coordinates of the object. It describes the geometry as if the object was alone and centered around the origin.
> - modelMatrix * in.position gives the world coordinates of the points, telling where it is relatively to a global static frame.
> - viewMatrix * modelMatrix * in.position gives the camera coordinates, or view coordinates. This is the coordinates of the point as seen from the camera. You can think of it as if instead of moving the eye, we actually move and rotate the whole scene in the opposite direction.
> - multiplying by projectionMatrix applies the projection [...] to give us clip coordinates.
> - the fixed pipeline divides the clip coordinates by its w, which gives the NDC (normalized device coordinates).



### World coordinate system

- x is the West to East axis (-x = West, +x = East)
- y is the South to North axis (-y = South, +y = North)
- z is the down to up axis (-z = down, +z = up)

Relative to NDC, the world needs to be
- rotated around the x axis by -90°g
- mirrored on the y axis

... I guess?


### Axes

<img src="https://www1.grc.nasa.gov/wp-content/uploads/rotations.jpg" height="400">


### Normalized device coordinates

- -1.0 ≤ x ≤ 1.0
- -1.0 ≤ y ≤ 1.0
- 0.0 ≤ z ≤ 1.0

<img src="https://www.w3.org/TR/webgpu/img/normalized-device-coordinates.svg" height="400">


### Clip space

position output of a vertex shader

> If point p = (p.x, p.y, p.z, p.w) is in the clip volume, then its normalized device coordinates are (p.x ÷ p.w, p.y ÷ p.w, p.z ÷ p.w).


### Framebuffer coordinates

match window coordinates

pixel coordinates on screen

<img src="https://www.w3.org/TR/webgpu/img/framebuffer-coordinates.svg" height="400">


### Viewport Coordinates

match fragment coordinates

framebuffer coordinates + z depth

0.0 ≤ z ≤ 1.0, can be changed


### Texture coordinates

<img src="https://www.w3.org/TR/webgpu/img/uv-coordinates.svg" height="400">

- 0 ≤ u ≤ 1.0
- 0 ≤ v ≤ 1.0
- 0 ≤ w ≤ 1.0 (3D coordinates)

> (0.0, 0.0, 0.0) is in the first texel in texture memory address order.  
(1.0, 1.0, 1.0) is in the last texel texture memory address order.


## Scripting

### Language candidates


### Lua

https://www.lua.org/

http://luajit.org/

https://luau.org/


advantages:
- well known
- fast (proven, at least with LuaJit)
- simple

disadvantages:
- anemic type system
- quirky syntax with gotchas
- lots of variants with different features and performance characteristics


### Umka

https://github.com/vtereshkov/umka-lang

advantages
- static types
- interfaces
- fast (it says so)
- relatively well readable

disadvantages
- some weird syntax
- not well known
- questionable support


### Cyber

https://cyberscript.dev/

advantages
- static types
- fast (it says so)
- well readable

disadvantages
- not well known
- questionable support


### Berry

https://berry-lang.github.io/

advantages
- fast (it says so)
- well readable

disadvantages
- not well known
- questionable support

