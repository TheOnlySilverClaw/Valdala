struct Vertex {
  @location(0) position: vec3<f32>,
  @location(1) uv: vec2<f32>,
  @location(2) textureIndex: f32
}

struct Fragment {
  @builtin(position) position: vec4<f32>,
  @location(1) uv: vec2<f32>,
  @location(2) textureIndex: f32
}

@group(0) @binding(0) var<uniform> projection: mat4x4<f32>;

@vertex
fn vertex(vertex: Vertex) -> Fragment {

  var fragment: Fragment;
  fragment.position = projection * vec4<f32>(vertex.position.xyz, 1.0);
  fragment.uv = vertex.uv;
  fragment.textureIndex = vertex.textureIndex;

  return fragment;
}

@group(0) @binding(1) var textureSampler: sampler;
@group(0) @binding(2) var textureArray: texture_2d_array<f32>;

@fragment
fn fragment(fragment: Fragment) -> @location(0) vec4<f32> {

  // TODO figure out how to send mixed types
  var i: u32 = u32(fragment.textureIndex);
  let textureColor = textureSample(textureArray, textureSampler, fragment.uv, i);
  return textureColor;
}
