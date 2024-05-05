@group(0) @binding(0) var<uniform> color: vec4<f32>;

@vertex
fn vertex(@location(0) position2d: vec2<f32>) -> @builtin(position) vec4<f32> {

  return vec4<f32>(position2d.x, position2d.y, 0.0, 1.0);
}

@fragment
fn fragment() -> @location(0) vec4<f32> {
  return color;
}
