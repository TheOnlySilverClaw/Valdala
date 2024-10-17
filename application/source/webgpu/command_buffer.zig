const shared = @import("shared.zig");

pub const CommandBuffer = *opaque {
    
    pub fn setLabel(command_buffer: CommandBuffer, label: ?[*:0]const u8) void {
        wgpuCommandBufferSetLabel(command_buffer, label);
    }

    pub fn reference(command_buffer: CommandBuffer) void {
        wgpuCommandBufferReference(command_buffer);
    }

    pub fn release(command_buffer: CommandBuffer) void {
        wgpuCommandBufferRelease(command_buffer);
    }
};

pub const CommandBufferDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null
};

extern fn wgpuCommandBufferSetLabel(command_buffer: CommandBuffer, label: ?[*:0]const u8) void;
extern fn wgpuCommandBufferReference(command_buffer: CommandBuffer) void;
extern fn wgpuCommandBufferRelease(command_buffer: CommandBuffer) void;
