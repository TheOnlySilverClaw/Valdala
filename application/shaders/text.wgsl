struct Vertex {
    @location(0) position: vec2<f32>,
    @location(1) uv: vec2<f32>
}

struct Fragment {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>
}

// never changes
@group(0) @binding(0) var textureSampler: sampler;

// changes if current texture cannot hold all glyphs
@group(1) @binding(0) var glyphTexture: texture_2d<f32>;
@group(1) @binding(1) var<uniform> textColor: vec4<f32>;


@vertex
fn vertex(vertex: Vertex) -> Fragment {

    var fragment: Fragment;
    fragment.position = vec4<f32>(vertex.position, 0, 1);
    fragment.uv = vertex.uv;
    return fragment;
}

@fragment
fn fragment(fragment: Fragment) -> @location(0) vec4<f32> {

    let textureColor = textureSample(glyphTexture, textureSampler, fragment.uv);
    return textureColor;
}