struct Vertex {
  @location(0) position: vec3<f32>,
  @location(1) uv: vec2<f32>,
}

struct Fragment {
  @builtin(position) position: vec4<f32>,
  @location(1) uv: vec2<f32>,
}

struct Entity {
  transform: mat4x4<f32>,
}

struct Material {
  base_color_factor: vec4<f32>
}

@group(0) @binding(0) var<uniform> projection: mat4x4<f32>;
@group(0) @binding(1) var textureSampler: sampler;

@group(1) @binding(0) var<uniform> material: vec4<f32>;
@group(1) @binding(1) var colorTexture: texture_2d<f32>;

@group(2) @binding(0) var<uniform> entity: Entity;


@vertex
fn vertex(vertex: Vertex) -> Fragment {

  var fragment: Fragment;
  fragment.position =  projection * entity.transform * vec4<f32>(vertex.position, 1.0);
  fragment.uv = vertex.uv;

  return fragment;
}


@fragment
fn fragment(fragment: Fragment) -> @location(0) vec4<f32> {

  let textureColor = textureSample(colorTexture, textureSampler, fragment.uv);
  return material;
}
