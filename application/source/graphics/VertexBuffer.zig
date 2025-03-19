const webgpu = @import("webgpu");
const VertexLayout = @import("VertexLayout.zig");


pub fn VertexBuffer(comptime T: type, formats: []const webgpu.VertexFormat) type {

    return struct {
        
        const Self = @This();
        
        const attributes = VertexLayout.computeAttributes(formats);

        comptime {
            const element_size = VertexLayout.computeArrayStride(formats);
            if(element_size != @sizeOf(T)) {
                const print = @import("std").fmt.comptimePrint;
                @compileError(print("calculated element size {} does not match type size {} of type {s}",
                    .{element_size, @sizeOf(T), @typeName(T)}));
            }
        }

        length: u32,
        label: webgpu.StringView = .{},
        handle: *webgpu.Buffer = undefined,


        pub fn create(self: *Self, device: *webgpu.Device) void {
            
            const descriptor = webgpu.BufferDescriptor {
                .label = self.label,
                .size = self.size(),
                .usage = .{ .vertex = true, .copy_dst = true },
                .mapped_at_creation = 0
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

        pub fn upload(self: Self, queue: *webgpu.Queue, data: []const T, offset: u64) void {
            queue.writeBuffer(self.handle, T, data, offset);
        }
    };
}


