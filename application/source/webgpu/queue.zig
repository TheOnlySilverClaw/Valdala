const shared = @import("shared.zig");
const texture = @import("texture.zig");
const buffer = @import("buffer.zig");
const command_buffer = @import("command_buffer.zig");

pub const Queue = *opaque {

    pub fn onSubmittedWorkDone(queue: Queue,
        value: u64, callback: QueueWorkDoneCallback, userdata: ?*anyopaque) void {
        wgpuQueueOnSubmittedWorkDone(queue, value, callback, userdata);
    }

    pub fn setLabel(queue: Queue, label: ?[*:0]const u8) void {
        wgpuQueueSetLabel(queue, label);
    }

    pub fn submit(queue: Queue, commands: []const command_buffer.CommandBuffer) void {
        wgpuQueueSubmit(queue, @as(u32, @intCast(commands.len)), commands.ptr);
    }

    pub fn writeBuffer(queue: Queue,
        target: buffer.Buffer, offset: u64, comptime T: type, data: []const T) void {
        wgpuQueueWriteBuffer(
            queue, target, offset,
            @as(*const anyopaque, @ptrCast(data.ptr)),
            @as(u64, @intCast(data.len)) * @sizeOf(T),
        );
    }

    pub fn writeTexture(queue: Queue,
        destination: texture.ImageCopyTexture, layout: *texture.TextureDataLayout,
        extent: *shared.Extent3D, comptime T: type, data: []const T) void {
        
        wgpuQueueWriteTexture(queue, destination,
            @as(*const anyopaque, @ptrCast(data.ptr)),
            @as(usize, @intCast(data.len)) * @sizeOf(T),
            layout, extent);
    }

    pub fn reference(queue: Queue) void {
        wgpuQueueReference(queue);
    }

    pub fn release(queue: Queue) void {
        wgpuQueueRelease(queue);
    }
};

pub const QueueDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
};

pub const QueueWorkDoneCallback = *const fn (
    status: QueueWorkDoneStatus,
    userdata: ?*anyopaque,
) callconv(.C) void;

pub const QueueWorkDoneStatus = enum(u32) {
    success,
    failure,
    unknown,
    device_lost
};


extern fn wgpuQueueOnSubmittedWorkDone(queue: Queue,
    signal_value: u64, callback: QueueWorkDoneCallback, userdata: ?*anyopaque) void;

extern fn wgpuQueueSetLabel(queue: Queue, label: ?[*:0]const u8) void;

extern fn wgpuQueueSubmit(queue: Queue,
    count: u32, commands: [*]const command_buffer.CommandBuffer) void;

extern fn wgpuQueueWriteBuffer(queue: Queue,
    target: buffer.Buffer, offset: u64, data: *const anyopaque, size: u64) void;

extern fn wgpuQueueWriteTexture(queue: Queue,
    destination: *const texture.ImageCopyTexture, data: *const anyopaque,
    size: u64, layout: *const texture.TextureDataLayout, extent: *const shared.Extent3D) void;

extern fn wgpuQueueReference(queue: Queue) void;

extern fn wgpuQueueRelease(queue: Queue) void;