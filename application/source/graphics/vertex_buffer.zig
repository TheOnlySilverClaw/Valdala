const webgpu = @import("webgpu");
const binding = webgpu.buffer;
const layout = @import("vertex_layout.zig");
const Attribute = webgpu.render_pipeline.VertexAttribute;
const Format = webgpu.render_pipeline.VertexFormat;

pub fn VertexBuffer(comptime T: type, comptime attribute_formats: []const Format) type {

    return struct {
        
        const Self = @This();

        pub const formats: [attribute_formats.len] Format = attribute_formats;
        pub const element_size = layout.elementSize(attribute_formats);
        
        comptime {
            if(element_size != @sizeOf(T)) {
                const print = @import("std").fmt.comptimePrint;
                @compileError(print("calculated element size {} does not match type size {} of type {s}",
                    .{element_size, @sizeOf(T), @typeName(T)}));
            }
        }

        handle: binding.Buffer,
        length: usize,

        pub fn create(device: webgpu.device.Device, length: usize, label: ?[*:0]const u8) Self {
            
            const descriptor = webgpu.buffer.BufferDescriptor {
                .label = label,
                .size = length * element_size,
                .usage = .{ .vertex = true, .copy_dst = true },
                .mapped_at_creation = false
            };

            const handle = device.createBuffer(&descriptor);

            return .{
                .handle = handle,
                .length = length
            };
        }

        pub fn size(self: Self) usize {
            return self.length * element_size;
        }

        pub fn destroy(self: Self) void {
            self.handle.destroy();
            self.handle.release();
        }

        pub fn upload(self: Self, queue: webgpu.queue.Queue, data: []const T, offset: u32) void {
            queue.writeBuffer(self.handle, offset, data.ptr, data.len * element_size);
        }
    };
}