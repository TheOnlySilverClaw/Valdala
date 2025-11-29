struct Vertex {
  @location(0) position: vec3<f32>,
  @location(1) uv: vec2<f32>,
  @location(2) normal: vec3<f32>,
  @location(3) texture: u32,
  @builtin(vertex_index) vertex_index: u32
}

struct Fragment {
  @builtin(position) position: vec4<f32>,
  @location(1) uv: vec2<f32>,
  @location(2) texture: u32,
  @location(3) barycentric_coord_a: vec4<f32>,
  @location(4) barycentric_coord_b: vec4<f32>
}


@group(0) @binding(0) var<uniform> projection: mat4x4<f32>;
fn wireframe(bary_a: vec4<f32>, bary_b: vec4<f32>, input_color: vec4<f32>) -> vec4<f32> {
  let wireframe_threshold = 0.02;
  for (var i = 0; i < 4; i++) {
    if (bary_a[i] > 0.0 && bary_a[i] < wireframe_threshold) {
        return vec4(0.0, 0.0, 0.0, 1.0);
      }
    if (bary_b[i] > 0.0 && bary_b[i] < wireframe_threshold) {
        return vec4(0.0, 0.0, 0.0, 1.0);
      }

  }
  return input_color;
}
@vertex
fn vertex(vertex: Vertex) -> Fragment {

  var fragment: Fragment;

  // This is predicated on the assumption that the indeces of triangles will be within.
  // 7 of each other.
  fragment.barycentric_coord_a = vec4();
  fragment.barycentric_coord_b = vec4();
  let vi = vertex.vertex_index % 7;
  if (vi > 4) {
    fragment.barycentric_coord_a[vi%4] = 1.0;
  } else {
    fragment.barycentric_coord_b[vi%4] = 1.0;
  }

  fragment.position = projection * vec4<f32>(vertex.position, 1.0);
  fragment.uv = vertex.uv;
  fragment.texture = vertex.texture;

  return fragment;
}

@group(0) @binding(1) var textureSampler: sampler;
@group(0) @binding(2) var textureArray: texture_2d_array<f32>;

@fragment
fn fragment(fragment: Fragment) -> @location(0) vec4<f32> {

  let textureColor = textureSample(textureArray, textureSampler, fragment.uv, fragment.texture);
  return wireframe(fragment.barycentric_coord_a, fragment.barycentric_coord_b, textureColor);
}
