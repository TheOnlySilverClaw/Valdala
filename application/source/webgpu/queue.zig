const shared = @import("shared.zig");
const texture = @import("texture.zig");
const buffer = @import("buffer.zig");
const command_buffer = @import("command_buffer.zig");

pub const Queue = *opaque {

    pub const onSubmittedWorkDone = wgpuQueueOnSubmittedWorkDone;

    pub const setLabel = wgpuQueueSetLabel;

    pub fn submit(queue: Queue, commands: []const command_buffer.CommandBuffer) void {
        wgpuQueueSubmit(queue, commands.len, commands.ptr);
    }

    pub fn writeBuffer(queue: Queue,
        target: buffer.Buffer, comptime T: type, data: []const T, offset: u64) void {
        wgpuQueueWriteBuffer(queue, target, offset, data.ptr, data.len * @sizeOf(T));
    }

    // TODO maybe change as soon as casting between slices works
    pub const writeTexture = wgpuQueueWriteTexture;

    pub const reference = wgpuQueueReference;

    pub const release = wgpuQueueRelease;
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
    count: usize, commands: [*]const command_buffer.CommandBuffer) void;

extern fn wgpuQueueWriteBuffer(queue: Queue,
    target: buffer.Buffer, offset: u64, data: *const anyopaque, size: usize) void;

extern fn wgpuQueueWriteTexture(queue: Queue,
    destination: *const texture.ImageCopyTexture,
    data: *const anyopaque,
    size: usize,
    layout: *const texture.TextureDataLayout,
    extent: *const shared.Extent3D) void;

extern fn wgpuQueueReference(queue: Queue) void;

extern fn wgpuQueueRelease(queue: Queue) void;