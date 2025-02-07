const webgpu = @import("webgpu");
const Attribute = webgpu.VertexAttribute;
const Format = webgpu.VertexFormat;


pub fn VertexBuffer(comptime T: type, attribute_formats: []const Format) type {

    return struct {
        
        const Self = @This();
        
        const formats = attribute_formats;
        const attributes = map_attributes();

        comptime {
            const element_size = elementSize(formats);
            if(element_size != @sizeOf(T)) {
                const print = @import("std").fmt.comptimePrint;
                @compileError(print("calculated element size {} does not match type size {} of type {s}",
                    .{element_size, @sizeOf(T), @typeName(T)}));
            }
        }

        length: usize,
        label: ?[*:0]const u8 = null,

        handle: webgpu.Buffer = undefined,


        pub fn layout() webgpu.render_pipeline.VertexBufferLayout {
            return .{
                .attributes = &attributes,
                .attribute_count = attributes.len,
                .array_stride = elementSize(attribute_formats)
            };
        }

        pub fn map_attributes() [formats.len]Attribute {
    
            var mapped: [formats.len]Attribute = undefined;
            var offset: u64 = 0;
            
            for(0.., attribute_formats) |location, format| {
                
                const byte_size = byteSize(format);
                const attribute = Attribute {
                    .shader_location = @intCast(location),
                    .format = format,
                    .offset = offset
                };
                mapped[location] = attribute;
                offset += byte_size;
            }
            
            return mapped;
        }

        pub fn create(self: *Self, device: webgpu.device.Device) void {
            
            const descriptor = webgpu.buffer.BufferDescriptor {
                .label = self.label,
                .size = self.size(),
                .usage = .{ .vertex = true, .copy_dst = true },
                .mapped_at_creation = false
            };

            self.handle = device.createBuffer(&descriptor);
        }

        pub fn size(self: Self) usize {
            return self.length * @sizeOf(T);
        }

        pub fn destroy(self: Self) void {
            self.handle.destroy();
            self.handle.release();
        }

        pub fn upload(self: Self, queue: webgpu.queue.Queue, data: []const T) void {
            self.uploadAfter(queue, data, 0);
        }

        pub fn uploadAfter(self: Self, queue: webgpu.queue.Queue, data: []const T, offset: u64) void {
            queue.writeBuffer(self.handle, T, data, offset);
        }
    };
}


pub fn elementSize(formats: []const Format) u32 {

    var total: u32 = 0;
    for(formats) |format| {
        const size = byteSize(format);
        total += size;
    }
    return total;
}

pub fn byteSize(format: Format) u8 {

    return switch (format) {
        .undefined => 0,
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
