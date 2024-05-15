struct Vertex {
  @builtin(position) position: vec4<f32>,
  @location(0) color: vec4<f32>,
}

@vertex
fn vertex(
  @location(0) position2d: vec2<f32>,
  @location(1) color: vec4<f32>
  ) -> Vertex {

  var vertex: Vertex;
  vertex.position = vec4<f32>(position2d.x, position2d.y, 0.0, 1.0);
  vertex.color = color;
  return vertex;
}

@fragment
fn fragment(vertex: Vertex) -> @location(0) vec4<f32> {
  return vertex.color;
}
