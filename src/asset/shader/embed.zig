pub const text = @embedFile("text.wgsl");
pub const enity = @embedFile("entity.wgsl");
pub const terrain = if (@import("build_options").debug_wireframe) 
    @embedFile("terrain_debug.wgsl")
 else 
    @embedFile("terrain.wgsl");
