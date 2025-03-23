struct Vertex {
  @location(0) position: vec3<f32>,
  @location(1) uv: vec2<f32>,
  @location(2) textureIndex: u32
}

struct Fragment {
  @builtin(position) position: vec4<f32>,
  @location(1) uv: vec2<f32>,
  @location(2) textureIndex: u32,
  @location(3) worldPos: vec3<f32>,
}

@group(0) @binding(0) var<uniform> projection: mat4x4<f32>;

@vertex
fn vertex(vertex: Vertex) -> Fragment {
    var fragment: Fragment;
    
    let worldPosition = vec4<f32>(vertex.position, 1.0);
    
    fragment.worldPos = worldPosition.xyz;  // Pass world position
    fragment.position = projection * vec4<f32>(vertex.position, 1.0);
    fragment.uv = vertex.uv;
    fragment.textureIndex = vertex.textureIndex;

    return fragment;
}

@group(0) @binding(1) var textureSampler: sampler;
@group(0) @binding(2) var textureArray: texture_2d_array<f32>;

@fragment
fn fragment(fragment: Fragment) -> @location(0) vec4<f32> {
    let white = vec3<f32>(0.05, 0.05, 0.05);
    let black = vec3<f32>(0.08, 0.08, 0.08);

    let gridSize = 5.1; // Adjust for finer or larger grid
    let r = length(fragment.worldPos) * 0.05;
    let x = floor(fragment.worldPos.x / gridSize);
    let y = floor(fragment.worldPos.y / gridSize); // Use Z to align with world ground

    // let checker = fract((x + y) * 0.5) * 2.0;
    let checker = (x + y) % 2.0;
    // let color = mix(white, black, checker);
    let color = select(white, black, checker == 0.0);
  
    return vec4<f32>(color, 1.0);
}
