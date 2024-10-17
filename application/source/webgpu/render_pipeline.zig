const shared = @import("shared.zig");
const shader = @import("shader.zig");
const layout = @import("pipeline_layout.zig");
const buffer = @import("buffer.zig");
const texture = @import("texture.zig");
const texture_view = @import("texture_view.zig");
const device = @import("device.zig");
const bind_group_layout = @import("bind_group_layout.zig");


pub const RenderPipeline = *opaque {

    pub fn getBindGroupLayout(pipeline: RenderPipeline, index: u32) bind_group_layout.BindGroupLayout {
        return wgpuRenderPipelineGetBindGroupLayout(pipeline, index);
    }

    pub fn setLabel(pipeline: RenderPipeline, label: ?[*:0]const u8) void {
        wgpuRenderPipelineSetLabel(pipeline, label);
    }

    pub fn reference(pipeline: RenderPipeline) void {
        wgpuRenderPipelineReference(pipeline);
    }

    pub fn release(pipeline: RenderPipeline) void {
        wgpuRenderPipelineRelease(pipeline);
    }
};

pub const BlendFactor = enum(u32) {
    zero,
    one,
    src,
    one_minus_src,
    src_alpha,
    one_minus_src_alpha,
    dst,
    one_minus_dst,
    dst_alpha,
    one_minus_dst_alpha,
    src_alpha_saturated,
    constant,
    one_minus_constant
};

pub const BlendOperation = enum(u32) {
    add,
    subtract,
    reverse_subtract,
    min,
    max
};

pub const CreateRenderPipelineAsyncCallback = *const fn (
    status: device.CreatePipelineAsyncStatus,
    pipeline: RenderPipeline,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque
) callconv(.C) void;

pub const CullMode = enum(u32) {
    none,
    front,
    back
};

pub const FrontFace = enum(u32) {
    counter_clockwise,
    clockwise
};

pub const PrimitiveTopology = enum(u32) {
    point_list,
    line_list,
    line_strip,
    triangle_list,
    triangle_strip
};

pub const StencilOperation = enum(u32) {
    keep,
    zero,
    replace,
    invert,
    increment_lamp,
    decrement_clamp,
    increment_wrap,
    decrement_wrap
};

pub const VertexFormat = enum(u32) {
    undefined,
    uint8x2,
    uint8x4,
    sint8x2,
    sint8x4,
    unorm8x2,
    unorm8x4,
    snorm8x2,
    snorm8x4,
    uint16x2,
    uint16x4,
    sint16x2,
    sint16x4,
    unorm16x2,
    unorm16x4,
    snorm16x2,
    snorm16x4,
    float16x2,
    float16x4,
    float32,
    float32x2,
    float32x3,
    float32x4,
    uint32,
    uint32x2,
    uint32x3,
    uint32x4,
    sint32,
    sint32x2,
    sint32x3,
    sint32x4
};

pub const VertexStepMode = enum(u32) {
    vertex,
    instance,
    unused
};

pub const ColorWriteMask = packed struct(u32) {
    red: bool = false,
    green: bool = false,
    blue: bool = false,
    alpha: bool = false,
    _padding: u28 = 0,

    pub const all = ColorWriteMask{
        .red = true,
        .green = true,
        .blue = true,
        .alpha = true
    };
};

pub const VertexAttribute = extern struct {
    format: VertexFormat,
    offset: u64,
    shader_location: u32
};

pub const VertexBufferLayout = extern struct {
    array_stride: u64,
    step_mode: VertexStepMode = .vertex,
    attribute_count: usize,
    attributes: [*]const VertexAttribute
};

pub const VertexState = extern struct {
    next: ?*const shared.ChainedStruct = null,
    module: shader.ShaderModule,
    entry_point: [*:0]const u8,
    constant_count: usize = 0,
    constants: ?[*]const shared.ConstantEntry = null,
    buffer_count: usize = 0,
    buffers: ?[*]const VertexBufferLayout = null
};

pub const BlendComponent = extern struct {
    operation: BlendOperation = .add,
    src_factor: BlendFactor = .one,
    dst_factor: BlendFactor = .zero
};

pub const BlendState = extern struct {
    color: BlendComponent,
    alpha: BlendComponent
};

pub const ColorTargetState = extern struct {
    next: ?*const shared.ChainedStruct = null,
    format: texture.TextureFormat,
    blend: ?*const BlendState = null,
    write_mask: ColorWriteMask = ColorWriteMask.all
};

pub const FragmentState = extern struct {
    next: ?*const shared.ChainedStruct = null,
    module: shader.ShaderModule,
    entry_point: [*:0]const u8,
    constant_count: usize = 0,
    constants: ?[*]const shared.ConstantEntry = null,
    target_count: usize = 0,
    targets: ?[*]const ColorTargetState = null
};

pub const PrimitiveState = extern struct {
    next: ?*const shared.ChainedStruct = null,
    topology: PrimitiveTopology = .triangle_list,
    strip_index_format: buffer.IndexFormat = .undefined,
    front_face: FrontFace = .counter_clockwise,
    cull_mode: CullMode = .none
};

pub const StencilFaceState = extern struct {
    compare: shared.CompareFunction = .always,
    fail_operation: StencilOperation = .keep,
    depth_fail_operation: StencilOperation = .keep,
    pass_operation: StencilOperation = .keep
};

pub const DepthStencilState = extern struct {
    next: ?*const shared.ChainedStruct = null,
    format: texture.TextureFormat,
    depth_write_enabled: bool = false,
    depth_compare: shared.CompareFunction = .always,
    stencil_front: StencilFaceState = .{},
    stencil_back: StencilFaceState = .{},
    stencil_read_mask: u32 = shared.Undefined,
    stencil_write_mask: u32 = shared.Undefined,
    depth_bias: i32 = 0,
    depth_bias_slope_scale: f32 = 0.0,
    depth_bias_clamp: f32 = 0.0
};

pub const MultisampleState = extern struct {
    next: ?*const shared.ChainedStruct = null,
    count: u32 = 1,
    mask: u32 = shared.Undefined,
    alpha_to_coverage_enabled: bool = false
};

pub const RenderPipelineDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    layout: ?layout.PipelineLayout = null,
    vertex: VertexState,
    primitive: PrimitiveState = .{},
    depth_stencil: ?*const DepthStencilState = null,
    multisample: MultisampleState = .{},
    fragment: ?*const FragmentState = null
};


extern fn wgpuRenderPipelineGetBindGroupLayout(pipeline: RenderPipeline, index: u32) bind_group_layout.BindGroupLayout;

extern fn wgpuRenderPipelineSetLabel(pipeline: RenderPipeline, label: ?[*:0]const u8) void;

extern fn wgpuRenderPipelineReference(pipeline: RenderPipeline) void;

extern fn wgpuRenderPipelineRelease(pipeline: RenderPipeline) void;
