struct Vertex {
  @builtin(position) position: vec4<f32>,
  
  @location(1) uv: vec2<f32>,
  @location(2) textureIndex: f32
}

@group(0) @binding(0) var<uniform> projection: mat4x4<f32>;

@vertex
fn vertex(
  @location(0) position: vec3<f32>,
  @location(1) uv: vec2<f32>,
  @location(2) textureIndex: f32
) -> Vertex {


  var vertex: Vertex;
  // vertex.position = projection * vec4<f32>(position.x, position.y, position.z, 1.0);
  vertex.position = projection * vec4<f32>(position.x, position.y, position.z, 1.0);
  vertex.uv = uv;
  vertex.textureIndex = textureIndex;
  
  return vertex;
}

@group(0) @binding(1) var textureSampler: sampler;
// @group(0) @binding(1) var textureArray: texture_2d_array<f32>;
@group(0) @binding(2) var colorTexture: texture_2d<f32>;

@fragment
fn fragment(
  vertex: Vertex
) -> @location(0) vec4<f32> {

  // TODO figure out how to send mixed types
  // var i: u32 = u32(vertex.textureIndex);
  let textureColor = textureSample(colorTexture, textureSampler, vertex.uv);
  return textureColor; 
}