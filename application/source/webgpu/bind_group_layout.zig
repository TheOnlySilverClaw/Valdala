const shared = @import("shared.zig");
const texture = @import("texture.zig");
const texture_view = @import("texture_view.zig");

pub const BindGroupLayout = *opaque {
    pub fn setLabel(layout: BindGroupLayout, label: ?[*:0]const u8) void {
        wgpuBindGroupLayoutSetLabel(layout, label);
    }

    pub fn reference(layout: BindGroupLayout) void {
        wgpuBindGroupLayoutReference(layout);
    }

    pub fn release(layout: BindGroupLayout) void {
        wgpuBindGroupLayoutRelease(layout);
    }
};

pub const BindGroupLayoutDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    entry_count: usize,
    entries: ?[*]const BindGroupLayoutEntry,
};

pub const BindGroupLayoutEntry = extern struct {
    next: ?*const shared.ChainedStruct = null,
    binding: u32,
    visibility: ShaderStage,
    buffer: BufferBindingLayout = .{ .type = .undefined },
    sampler: SamplerBindingLayout = .{ .type = .undefined },
    texture: TextureBindingLayout = .{ .type = .undefined, .view_dimension = .@"2d", .multisampled = false },
    storage_texture: StorageTextureBindingLayout = .{
        .format = .undefined,
        .access = .{
            .write = false,
            .read = false
        },
        .view_dimension = .@"2d"
    }
};

pub const BufferBindingLayout = extern struct {
    next: ?*const shared.ChainedStruct = null,
    type: BufferBindingType = .uniform,
    has_dynamic_offset: bool = false,
    min_binding_size: u64 = 0,
};

pub const BufferBindingType = enum(u32) {
    undefined,
    uniform,
    storage,
    read_only_storage
};

pub const SamplerBindingType = enum(u32) {
    undefined,
    filtering,
    non_filtering,
    comparison
};

pub const ShaderStage = packed struct(u32) {
    vertex: bool = false,
    fragment: bool = false,
    compute: bool = false,
    _padding: u29 = 0,
};

pub const StorageTextureAccess = packed struct(u32) {
    write: bool,
    read: bool,
    _padding: u30 = 0
};

pub const StorageTextureBindingLayout = extern struct {
    next: ?*const shared.ChainedStruct = null,
    access: StorageTextureAccess,
    format: texture.TextureFormat,
    view_dimension: texture_view.TextureViewDimension
};

pub const TextureSampleType = enum(u32) {
    undefined,
    float,
    unfilterable_float,
    depth,
    sint,
    uint
};

pub const SamplerBindingLayout = extern struct {
    next: ?*const shared.ChainedStruct = null,
    type: SamplerBindingType = .filtering
};

pub const TextureBindingLayout = extern struct {
    next: ?*const shared.ChainedStruct = null,
    type: TextureSampleType,
    view_dimension: texture_view.TextureViewDimension,
    multisampled: bool
};


extern fn wgpuBindGroupLayoutSetLabel(layout: BindGroupLayout, label: ?[*:0]const u8) void;

extern fn wgpuBindGroupLayoutReference(layout: BindGroupLayout) void;

extern fn wgpuBindGroupLayoutRelease(layout: BindGroupLayout) void;
