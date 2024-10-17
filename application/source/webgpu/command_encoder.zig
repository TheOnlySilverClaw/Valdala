const shared = @import("shared.zig");
const texture = @import("texture.zig");
const buffer = @import("buffer.zig");
const compute_pass = @import("compute_pass.zig");
const render_pass_encoder = @import("render_pass_encoder.zig");
const query = @import("query.zig");
const command_buffer = @import("command_buffer.zig");


pub const CommandEncoder = *opaque {
    
    pub fn beginComputePass(encoder: CommandEncoder,
        descriptor: ?*compute_pass.ComputePassDescriptor) compute_pass.ComputePassEncoder {
        return wgpuCommandEncoderBeginComputePass(encoder, descriptor);
    }

    pub fn beginRenderPass(encoder: CommandEncoder,
        descriptor: *render_pass_encoder.RenderPassDescriptor) render_pass_encoder.RenderPassEncoder {
        return wgpuCommandEncoderBeginRenderPass(encoder, descriptor);
    }

    pub fn clearBuffer(encoder: CommandEncoder, target: buffer.Buffer, offset: usize, size: usize) void {
        wgpuCommandEncoderClearBuffer(encoder, target, offset, size);
    }

    pub fn copyBufferToBuffer(encoder: CommandEncoder,
        source: buffer.Buffer, source_offset: usize,
        destination: buffer.Buffer, destination_offset: usize, size: usize) void {
        wgpuCommandEncoderCopyBufferToBuffer(encoder,
            source, source_offset, destination, destination_offset, size);
    }

    pub fn copyBufferToTexture(encoder: CommandEncoder,
        source: *ImageCopyBuffer, destination: *ImageCopyTexture, extent: *shared.Extent3D) void {
        wgpuCommandEncoderCopyBufferToTexture(encoder, source, destination, extent);
    }

    pub fn copyTextureToBuffer(encoder: CommandEncoder,
        source: *ImageCopyTexture, destination: *ImageCopyBuffer, extent: *shared.Extent3D) void {
        wgpuCommandEncoderCopyTextureToBuffer(encoder, source, destination, extent);
    }

    pub fn copyTextureToTexture(encoder: CommandEncoder,
        source: *ImageCopyTexture, destination: *ImageCopyTexture, extent: *shared.Extent3D) void {
        wgpuCommandEncoderCopyTextureToTexture(encoder, source, destination, extent);
    }

    pub fn finish(encoder: CommandEncoder, descriptor: ?*command_buffer.CommandBufferDescriptor) command_buffer.CommandBuffer {
        return wgpuCommandEncoderFinish(encoder, descriptor);
    }

    pub fn insertDebugMarker(encoder: CommandEncoder, label: [*:0]const u8) void {
        wgpuCommandEncoderInsertDebugMarker(encoder, label);
    }

    pub fn popDebugGroup(encoder: CommandEncoder) void {
        wgpuCommandEncoderPopDebugGroup(encoder);
    }

    pub fn pushDebugGroup(encoder: CommandEncoder, label: [*:0]const u8) void {
        wgpuCommandEncoderPushDebugGroup(encoder, label);
    }

    pub fn resolveQuerySet(encoder: CommandEncoder,
        query_set: query.QuerySet, first: u32, count: u32,
        destination: buffer.Buffer, offset: u64) void {
        wgpuCommandEncoderResolveQuerySet(encoder,
            query_set, first, count, destination, offset);
    }

    pub fn setLabel(encoder: CommandEncoder, label: ?[*:0]const u8) void {
        wgpuCommandEncoderSetLabel(encoder, label);
    }

    pub fn writeBuffer(encoder: CommandEncoder,
        target: buffer.Buffer, offset: u64, comptime T: type, data: []const T) void {
        wgpuCommandEncoderWriteBuffer(encoder,
            target, offset,
            @as([*]const u8, @ptrCast(data.ptr)),
            @as(u64, @intCast(data.len)) * @sizeOf(T));
    }

    pub fn writeTimestamp(encoder: CommandEncoder, query_set: query.QuerySet, index: u32) void {
        wgpuCommandEncoderWriteTimestamp(encoder, query_set, index);
    }

    pub fn reference(encoder: CommandEncoder) void {
        wgpuCommandEncoderReference(encoder);
    }

    pub fn release(encoder: CommandEncoder) void {
        wgpuCommandEncoderRelease(encoder);
    }
};

pub const CommandEncoderDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
};

pub const ImageCopyBuffer = extern struct {
    next: ?*const shared.ChainedStruct = null,
    layout: texture.TextureDataLayout,
    buffer: buffer.Buffer,
};

pub const ImageCopyTexture = extern struct {
    next: ?*const shared.ChainedStruct = null,
    texture: texture.Texture,
    mip_level: u32 = 0,
    origin: shared.Origin3D = .{},
    aspect: texture.TextureAspect = .all,
};


extern fn wgpuCommandEncoderBeginComputePass(encoder: CommandEncoder,
    descriptor: ?*const compute_pass.ComputePassDescriptor) compute_pass.ComputePassEncoder;

extern fn wgpuCommandEncoderBeginRenderPass(encoder: CommandEncoder,
    descriptor: *const render_pass_encoder.RenderPassDescriptor) render_pass_encoder.RenderPassEncoder;
    
extern fn wgpuCommandEncoderClearBuffer(encoder: CommandEncoder,
        buffer: buffer.Buffer, offset: usize, size: usize) void;

extern fn wgpuCommandEncoderCopyBufferToBuffer(encoder: CommandEncoder,
    source: buffer.Buffer, source_offset: usize,
    destination: buffer.Buffer, destination_offset: usize,
    size: usize) void;

extern fn wgpuCommandEncoderCopyBufferToTexture(encoder: CommandEncoder,
    source: *const ImageCopyBuffer, destination: *const ImageCopyTexture, extent: *const shared.Extent3D) void;

extern fn wgpuCommandEncoderCopyTextureToBuffer(encoder: CommandEncoder,
    source: *const ImageCopyTexture, destination: *const ImageCopyBuffer, extent: *const shared.Extent3D) void;

extern fn wgpuCommandEncoderCopyTextureToTexture(encoder: CommandEncoder,
    source: *const ImageCopyTexture, destination: *const ImageCopyTexture, extent: *const shared.Extent3D) void;

extern fn wgpuCommandEncoderFinish(encoder: CommandEncoder,
    descriptor: ?*const command_buffer.CommandBufferDescriptor) command_buffer.CommandBuffer;

extern fn wgpuCommandEncoderInjectValidationError(encoder: CommandEncoder, message: [*:0]const u8) void;

extern fn wgpuCommandEncoderInsertDebugMarker(encoder: CommandEncoder, marker_label: [*:0]const u8) void;

extern fn wgpuCommandEncoderPopDebugGroup(encoder: CommandEncoder) void;

extern fn wgpuCommandEncoderPushDebugGroup(encoder: CommandEncoder, group_label: [*:0]const u8) void;

extern fn wgpuCommandEncoderResolveQuerySet(encoder: CommandEncoder,
    query_set: query.QuerySet, first: u32, query: u32, destination: buffer.Buffer, offset: u64) void;

extern fn wgpuCommandEncoderWriteBuffer(encoder: CommandEncoder,
    target: buffer.Buffer, offset: u64, data: [*]const u8, size: u64) void;

extern fn wgpuCommandEncoderWriteTimestamp(encoder: CommandEncoder,
    query_set: query.QuerySet, index: u32) void;

extern fn wgpuCommandEncoderSetLabel(encoder: CommandEncoder, label: ?[*:0]const u8) void;

extern fn wgpuCommandEncoderReference(encoder: CommandEncoder) void;

extern fn wgpuCommandEncoderRelease(encoder: CommandEncoder) void;