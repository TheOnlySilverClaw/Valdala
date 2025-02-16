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
@group(1) @binding(1) var<uniform> screenSize: vec2<f32>;
@group(1) @binding(2) var<uniform> textColor: vec4<f32>;


@vertex
fn vertex(vertex: Vertex) -> Fragment {

    var fragment: Fragment;
    let x = 2 * vertex.position.x / screenSize.x - 1;
    let y = 1 - 2 * vertex.position.y / screenSize.y;
    fragment.position = vec4<f32>(x, y, 0, 1);
    fragment.uv = vertex.uv;
    return fragment;
}

@fragment
fn fragment(fragment: Fragment) -> @location(0) vec4<f32> {

    let textureColor = textureSample(glyphTexture, textureSampler, fragment.uv);
    let strength = textureColor.r;

    if(strength == 0) { discard; }

    return vec4<f32>(strength, strength, strength, 1) * textColor;
}