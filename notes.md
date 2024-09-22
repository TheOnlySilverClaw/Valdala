# Development notes

## Ressources

[WebGPU Specification](https://www.w3.org/TR/webgpu/)

[Learn WebGPU C++ Guide](https://eliemichel.github.io/LearnWebGPU/index.html) by Elie Michel

[WebGPU Samples](https://webgpu.github.io/webgpu-samples/)

[Learn OpenGL](https://learnopengl.com/) by Joey de Vries

[WebGPU Headers](https://github.com/webgpu-native/webgpu-headers/blob/main/webgpu.h)

[Carmen's Graphics Blog](https://carmencincotti.com/posts/categories/webgpu/)


## Coordinate System

### Normalized device coordinates

- -1.0 ≤ x ≤ 1.0
- -1.0 ≤ y ≤ 1.0
- 0.0 ≤ z ≤ 1.0

<img src="https://www.w3.org/TR/webgpu/img/normalized-device-coordinates.svg" height="300">


### Clip space

position output of a vertex shader

> If point p = (p.x, p.y, p.z, p.w) is in the clip volume, then its normalized device coordinates are (p.x ÷ p.w, p.y ÷ p.w, p.z ÷ p.w).


### Framebuffer coordinates

match window coordinates

pixel coordinates on screen

<img src="https://www.w3.org/TR/webgpu/img/framebuffer-coordinates.svg" height="300">


### Viewport Coordinates

match fragment coordinates

framebuffer coordinates + z depth

0.0 ≤ z ≤ 1.0, can be changed


### Texture coordinates

<img src="https://www.w3.org/TR/webgpu/img/uv-coordinates.svg" height="300">

- 0 ≤ u ≤ 1.0
- 0 ≤ v ≤ 1.0
- 0 ≤ w ≤ 1.0 (3D coordinates)

> (0.0, 0.0, 0.0) is in the first texel in texture memory address order.  
(1.0, 1.0, 1.0) is in the last texel texture memory address order.

