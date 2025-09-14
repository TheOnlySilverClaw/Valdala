struct Vertex {
    @location(0) position: vec2<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) color: vec4<f32>,
}

struct Fragment {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
    @location(1) color: vec4<f32>
}

// never changes
@group(0) @binding(0) var textureSampler: sampler;

@group(1) @binding(0) var glyphTexture: texture_2d<f32>;


@vertex
fn vertex(vertex: Vertex) -> Fragment {

    var fragment: Fragment;
    fragment.position = vec4<f32>(vertex.position.xy, 0.0, 1.0);
    fragment.uv = vertex.uv;
    fragment.color = vertex.color;

    return fragment;
}

@fragment
fn fragment(fragment: Fragment) -> @location(0) vec4<f32> {

    let textureColor = textureSample(glyphTexture, textureSampler, fragment.uv);
    let strength = textureColor[0];

    if(strength == 0.0) { discard; }

    return vec4<f32>(strength, strength, strength, 1.0) * fragment.color;
}