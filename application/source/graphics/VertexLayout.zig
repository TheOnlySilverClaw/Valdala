const webgpu = @import("webgpu");

pub fn byteSize(comptime format: webgpu.VertexFormat) u8 {

    return switch (format) {
        .undefined => @compileError("size not defined"),
        .uint8x2 => @sizeOf(u8) * 2,
        .uint8x4 => @sizeOf(u8) * 4,
        .sint8x2 => @sizeOf(i8) * 2,
        .sint8x4 => @sizeOf(i8) * 2,
        .unorm8x2 => @sizeOf(u8) * 2,
        .unorm8x4 => @sizeOf(u8) * 4,
        .snorm8x2 => @sizeOf(i8) * 2,
        .snorm8x4 => @sizeOf(i8) * 2,
        .uint16x2 => @sizeOf(u16) * 2,
        .uint16x4 => @sizeOf(u16) * 4,
        .sint16x2 => @sizeOf(i16) * 2,
        .sint16x4 => @sizeOf(i16) * 4,
        .unorm16x2 => @sizeOf(u16) * 2,
        .unorm16x4 => @sizeOf(u16) * 4,
        .snorm16x2 => @sizeOf(i16) * 2,
        .snorm16x4 => @sizeOf(i16) * 4,
        .float16x2 => @sizeOf(f16) * 2,
        .float16x4 => @sizeOf(f16) * 4,
        .float32 => @sizeOf(f32),
        .float32x2 => @sizeOf(f32) * 2,
        .float32x3 => @sizeOf(f32) * 3,
        .float32x4 => @sizeOf(f32) * 4,
        .uint32 => @sizeOf(u32),
        .uint32x2 => @sizeOf(u32) * 2,
        .uint32x3 => @sizeOf(u32) * 3,
        .uint32x4 => @sizeOf(u32) * 4,
        .sint32 => @sizeOf(i32),
        .sint32x2 => @sizeOf(i32) * 2,
        .sint32x3 => @sizeOf(i32) * 3,
        .sint32x4 => @sizeOf(i32) * 4,
    };
}

pub fn createBufferLayout(formats: []const webgpu.VertexFormat, stepMode: webgpu.VertexStepMode) webgpu.VertexBufferLayout {
    
    const attributes = computeAttributes(formats);
    const arrayStride = computeArrayStride(formats);

    return webgpu.VertexBufferLayout {
        .array_stride = arrayStride,
        .attribute_count = attributes.len,
        .attributes = attributes.ptr,
        .step_mode = stepMode
    };
}


pub fn computeAttributes(formats: []const webgpu.VertexFormat) []webgpu.VertexAttribute {

    var mapped: [formats.len]webgpu.VertexAttribute = undefined;
    var offset: u64 = 0;
    
    for(0.., formats) |location, format| {
        
        const byte_size = byteSize(format);
        const attribute = webgpu.VertexAttribute {
            .shader_location = @intCast(location),
            .format = format,
            .offset = offset
        };
        mapped[location] = attribute;
        // TODO handle alignment mismatch
        offset += byte_size;
    }
    
    return mapped;
}

pub fn computeArrayStride(formats: []const webgpu.VertexFormat) u64 {

    var sum = 0;
    for(formats) |format| {
        const size = byteSize(format);
        sum += size;
    }
    // TODO handle alignment mismatch
    return sum;
}