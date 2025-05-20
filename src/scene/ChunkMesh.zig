const webgpu = @import("webgpu");

pub const Vertex = extern struct {
    
    pub const Position = extern struct {
        x: f32,
        y: f32,
        z: f32
    };

    pub const Texture = extern struct {
        /// horizontal offset: left = 0.0 right = 1.0
        u: f32,
        /// vertical offset: top = 0.0 bottom = 1.0
        v: f32
    };

    pub const TextureIndex = u32;

    pub const format = [_]webgpu.VertexFormat {
        .float32x3,
        .float32x2,
        .uint32
    };

    position: Position,
    texture: Texture,
    texture_index: TextureIndex
};