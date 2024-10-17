const shared = @import("shared.zig");

pub const Buffer = *opaque {
    
    pub fn destroy(buffer: Buffer) void {
        wgpuBufferDestroy(buffer);
    }

    // `offset` has to be a multiple of 8 (otherwise `null` will be returned).
    // `@sizeOf(T) * len` has to be a multiple of 4 (otherwise `null` will be returned).
    pub fn getConstMappedRange(buffer: Buffer, comptime T: type, offset: usize, len: usize) ?[]const T {
        if (len == 0) return null;
        const ptr = wgpuBufferGetConstMappedRange(buffer, offset, @sizeOf(T) * len);
        if (ptr == null) return null;
        return @as([*]const T, @ptrCast(@alignCast(ptr)))[0..len];
    }

    // `offset` has to be a multiple of 8 (otherwise `null` will be returned).
    // `@sizeOf(T) * len` has to be a multiple of 4 (otherwise `null` will be returned).
    pub fn getMappedRange(buffer: Buffer, comptime T: type, offset: usize, len: usize) ?[]T {
        if (len == 0) return null;
        const ptr = wgpuBufferGetMappedRange(buffer, offset, @sizeOf(T) * len);
        if (ptr == null) return null;
        return @as([*]T, @ptrCast(@alignCast(ptr)))[0..len];
    }

    // `offset` has to be a multiple of 8 (Dawn's validation layer will warn).
    // `size` has to be a multiple of 4 (Dawn's validation layer will warn).
    // `size == 0` will map entire range (from 'offset' to the end of the buffer).
    pub fn mapAsync(buffer: Buffer,
        mode: MapMode, offset: usize, size: usize,
        callback: BufferMapCallback, userdata: ?*anyopaque) void {
        wgpuBufferMapAsync(buffer, mode, offset, size, callback, userdata);
    }

    pub fn setLabel(buffer: Buffer, label: ?[*:0]const u8) void {
        wgpuBufferSetLabel(buffer, label);
    }

    pub fn unmap(buffer: Buffer) void {
        wgpuBufferUnmap(buffer);
    }

    pub fn reference(buffer: Buffer) void {
        wgpuBufferReference(buffer);
    }

    pub fn release(buffer: Buffer) void {
        wgpuBufferRelease(buffer);
    }
};

pub const BufferDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    usage: BufferUsage,
    size: u64,
    mapped_at_creation: bool = false,
};

pub const BufferMapAsyncStatus = enum(u32) {
    success,
    validation_error,
    unknown,
    device_lost,
    destroyed_before_callback,
    unmapped_before_callback,
    mapping_already_pending,
    offset_out_of_range,
    size_out_of_range
};

pub const BufferMapCallback = *const fn (
    status: BufferMapAsyncStatus,
    userdata: ?*anyopaque
) callconv(.C) void;

pub const BufferMapState = enum(u32) {
    unmapped,
    pending,
    mapped
};

pub const BufferUsage = packed struct(u32) {
    map_read: bool = false,
    map_write: bool = false,
    copy_src: bool = false,
    copy_dst: bool = false,
    index: bool = false,
    vertex: bool = false,
    uniform: bool = false,
    storage: bool = false,
    indirect: bool = false,
    query_resolve: bool = false,
    _padding: u22 = 0
};

pub const MapMode = packed struct(u32) {
    read: bool = false,
    write: bool = false,
    _padding: u30 = 0
};

pub const IndexFormat = enum(u32) {
    undefined,
    uint16,
    uint32
};

extern fn wgpuBufferMapAsync(buffer: Buffer,
    mode: MapMode, offset: usize, size: usize,
    callback: BufferMapCallback, userdata: ?*anyopaque) void;

extern fn wgpuBufferGetConstMappedRange(buffer: Buffer, offset: usize, size: usize) ?*const anyopaque;
extern fn wgpuBufferGetMappedRange(buffer: Buffer, offset: usize, size: usize) ?*anyopaque;
extern fn wgpuBufferSetLabel(buffer: Buffer, label: ?[*:0]const u8) void;
extern fn wgpuBufferUnmap(buffer: Buffer) void;
extern fn wgpuBufferReference(buffer: Buffer) void;
extern fn wgpuBufferRelease(buffer: Buffer) void;
extern fn wgpuBufferDestroy(buffer: Buffer) void;
