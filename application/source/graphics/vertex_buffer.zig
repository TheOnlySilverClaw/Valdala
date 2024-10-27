const webgpu = @import("webgpu");
const binding = webgpu.buffer;
const layout = @import("vertex_layout.zig");
const Attribute = webgpu.render_pipeline.VertexAttribute;
const Format = webgpu.render_pipeline.VertexFormat;

pub fn VertexBuffer(comptime T: type, comptime attribute_formats: []const Format) type {

    return struct {
        
        const Self = @This();

        pub const formats: [attribute_formats.len] Format = attribute_formats;
        
        comptime {
            const element_size = layout.elementSize(attribute_formats);
            if(element_size != @sizeOf(T)) {
                const print = @import("std").fmt.comptimePrint;
                @compileError(print("calculated element size {} does not match type size {} of type {s}",
                    .{element_size, @sizeOf(T), @typeName(T)}));
            }
        }

        length: usize,
        label: ?[*:0]const u8 = null,

        handle: binding.Buffer = undefined,

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