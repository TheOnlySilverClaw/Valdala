const shared = @import("shared.zig");
const texture = @import("texture.zig");
const bundle = @import("render_bundle.zig");
const buffer = @import("buffer.zig");
const bind_group = @import("bind_group.zig");
const render_pipeline = @import("render_pipeline.zig");
const query = @import("query.zig");
const render_bundle = @import("render_bundle.zig");


pub const RenderPassEncoder = *opaque {
    
    pub fn beginOcclusionQuery(encoder: RenderPassEncoder, query_index: u32) void {
        wgpuRenderPassEncoderBeginOcclusionQuery(encoder, query_index);
    }

    pub fn draw(encoder: RenderPassEncoder,
        vertex_count: u32,instance_count: u32,first_vertex: u32, first_instance: u32) void {
        wgpuRenderPassEncoderDraw(encoder,
            vertex_count, instance_count, first_vertex, first_instance);
    }

    pub fn drawIndexed(encoder: RenderPassEncoder,
        index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        wgpuRenderPassEncoderDrawIndexed(encoder,
            index_count, instance_count, first_index, base_vertex, first_instance);
    }

    pub fn drawIndexedIndirect(encoder: RenderPassEncoder,
        indirect_buffer: buffer.Buffer, indirect_offset: u64) void {
        wgpuRenderPassEncoderDrawIndexedIndirect(encoder, indirect_buffer, indirect_offset);
    }

    pub fn drawIndirect(encoder: RenderPassEncoder,
        indirect_buffer: buffer.Buffer, indirect_offset: u64) void {
        wgpuRenderPassEncoderDrawIndirect(encoder, indirect_buffer, indirect_offset);
    }

    pub fn end(encoder: RenderPassEncoder, descriptor: *RenderPassEncoderDescriptor) bundle.RenderBundle {
        return wgpuRenderPassEncoderEnd(encoder, descriptor);
    }

    pub fn endOcclusionQuery(encoder: RenderPassEncoder) void {
        wgpuRenderPassEncoderEndOcclusionQuery(encoder);
    }

    pub fn executeBundles(encoder: RenderPassEncoder,
        count: u32, bundles: [*]const render_bundle.RenderBundle) void {
        wgpuRenderPassEncoderExecuteBundles(encoder, count, bundles);
    }

    pub fn setBlendConstant(encoder: RenderPassEncoder, color: *const shared.Color) void {
        wgpuRenderPassEncoderSetBlendConstant(encoder, color);
    }

    pub fn insertDebugMarker(encoder: RenderPassEncoder, label: [*:0]const u8) void {
        wgpuRenderPassEncoderInsertDebugMarker(encoder, label);
    }

    pub fn popDebugGroup(encoder: RenderPassEncoder) void {
        wgpuRenderPassEncoderPopDebugGroup(encoder);
    }

    pub fn pushDebugGroup(encoder: RenderPassEncoder, group_label: [*:0]const u8) void {
        wgpuRenderPassEncoderPushDebugGroup(encoder, group_label);
    }

    pub fn setBindGroup(encoder: RenderPassEncoder,
        index: u32, group: bind_group.BindGroup, dynamic_offsets: ?[]const u32) void {
        
        wgpuRenderPassEncoderSetBindGroup(encoder,
            index, group,
            if (dynamic_offsets) |offsets| @as(u32, @intCast(offsets.len)) else 0,
            if (dynamic_offsets) |offsets| offsets.ptr else null,
        );
    }

    pub fn setScissorRectangle(encoder: RenderPassEncoder,
        x: u32, y: u32, width: u32, height: u32) void {
        wgpuRenderPassEncoderSetScissorRect(encoder, x, y, width, height);
    }

    pub fn setStencilReference(encoder: RenderPassEncoder, ref: u32) void {
        wgpuRenderPassEncoderSetStencilReference(encoder, ref);
    }

    pub fn setViewport(encoder: RenderPassEncoder,
        x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
        wgpuRenderPassEncoderSetViewport(encoder, x, y, width, height, min_depth, max_depth);
    }

    pub fn setIndexBuffer(encoder: RenderPassEncoder,
        index_buffer: buffer.Buffer, format: buffer.IndexFormat, offset: u64, size: u64) void {
        wgpuRenderPassEncoderSetIndexBuffer(encoder, index_buffer, format, offset, size);
    }

    pub fn setLabel(encoder: RenderPassEncoder, label: ?[*:0]const u8) void {
        wgpuRenderPassEncoderSetLabel(encoder, label);
    }

    pub fn setPipeline(encoder: RenderPassEncoder, pipeline: render_pipeline.RenderPipeline) void {
        wgpuRenderPassEncoderSetPipeline(encoder, pipeline);
    }

    pub fn setVertexBuffer(encoder: RenderPassEncoder,
        slot: u32, vertex_buffer: buffer.Buffer, offset: u64, size: u64) void {
        wgpuRenderPassEncoderSetVertexBuffer(encoder, slot, vertex_buffer, offset, size);
    }

    pub fn reference(encoder: RenderPassEncoder) void {
        wgpuRenderPassEncoderReference(encoder);
    }

    pub fn release(encoder: RenderPassEncoder) void {
        wgpuRenderPassEncoderRelease(encoder);
    }
};

pub const RenderPassEncoderDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    color_formats_count: usize,
    color_formats: ?[*]const texture.TextureFormat,
    depth_stencil_format: texture.TextureFormat,
    sample_count: u32,
    depth_read_only: bool,
    stencil_read_only: bool,
};

pub const LoadOperation = enum(u32) {
    undefined,
    clear,
    load,
};

pub const RenderPassColorAttachment = extern struct {
    next: ?*const shared.ChainedStruct = null,
    view: ?texture.view.TextureView,
    resolve_target: ?texture.view.TextureView = null,
    load_op: LoadOperation,
    store_op: StoreOperation,
    clear_value: shared.Color
};

pub const RenderPassDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    color_attachment_count: usize,
    color_attachments: ?[*]const RenderPassColorAttachment,
    depth_stencil_attachment: ?*const RenderPassDepthStencilAttachment = null,
    occlusion_query_set: ?query.QuerySet = null,
    timestamp_write_count: usize = 0,
    timestamp_writes: ?[*]const RenderPassTimestampWrite = null,
};

pub const RenderPassDepthStencilAttachment = extern struct {
    view: texture.view.TextureView,
    depth_load_operation: LoadOperation = .undefined,
    depth_store_operation: StoreOperation = .undefined,
    depth_clear_value: f32 = 0.0,
    depth_read_only: bool = false,
    stencil_load_operation: LoadOperation = .undefined,
    stencil_store_operation: StoreOperation = .undefined,
    stencil_clear_value: u32 = 0,
    stencil_read_only: bool = false,
};

pub const RenderPassTimestampWrite = extern struct {
    query_set: query.QuerySet,
    start: u32,
    end: u32,
};

pub const StoreOperation = enum(u32) {
    undefined,
    store,
    discard
};


extern fn wgpuRenderPassEncoderBeginOcclusionQuery(encoder: RenderPassEncoder, index: u32) void;

extern fn wgpuRenderPassEncoderDraw(encoder: RenderPassEncoder,
    vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void;

extern fn wgpuRenderPassEncoderDrawIndexed(encoder: RenderPassEncoder,
    index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void;

extern fn wgpuRenderPassEncoderDrawIndexedIndirect(encoder: RenderPassEncoder,
    indirect_buffer: buffer.Buffer, indirect_offset: u64) void;

extern fn wgpuRenderPassEncoderDrawIndirect(encoder: RenderPassEncoder,
    indirect_buffer: buffer.Buffer, indirect_offset: u64) void;

extern fn wgpuRenderPassEncoderEnd(encoder: RenderPassEncoder,
    descriptor: *const bundle.RenderBundleDescriptor) bundle.RenderBundle;

extern fn wgpuRenderPassEncoderEndOcclusionQuery(encoder: RenderPassEncoder) void;

extern fn wgpuRenderPassEncoderExecuteBundles(encoder: RenderPassEncoder,
    count: u32, bundles: [*]const render_bundle.RenderBundle) void;

extern fn wgpuRenderPassEncoderSetScissorRect(encoder: RenderPassEncoder,
    x: u32, y: u32, width: u32, height: u32) void;

extern fn wgpuRenderPassEncoderSetStencilReference(encoder: RenderPassEncoder, ref: u32) void;
  
extern fn wgpuRenderPassEncoderSetBlendConstant(encoder: RenderPassEncoder, color: *const shared.Color) void;

extern fn wgpuRenderPassEncoderInsertDebugMarker(encoder: RenderPassEncoder, label: [*:0]const u8) void;

extern fn wgpuRenderPassEncoderPopDebugGroup(encoder: RenderPassEncoder) void;

extern fn wgpuRenderPassEncoderPushDebugGroup(encoder: RenderPassEncoder, label: [*:0]const u8) void;

extern fn wgpuRenderPassEncoderSetBindGroup(encoder: RenderPassEncoder,
    index: u32, group: bind_group.BindGroup,
    dynamic_offset_count: u32, dynamic_offsets: ?[*]const u32) void;

extern fn wgpuRenderPassEncoderSetIndexBuffer(encoder: RenderPassEncoder,
    index_buffer: buffer.Buffer, format: buffer.IndexFormat, offset: u64, size: u64) void;

extern fn wgpuRenderPassEncoderSetPipeline(encoder: RenderPassEncoder, pipeline: render_pipeline.RenderPipeline) void;

extern fn wgpuRenderPassEncoderSetLabel(encoder: RenderPassEncoder, label: ?[*:0]const u8) void;

extern fn wgpuRenderPassEncoderSetVertexBuffer(encoder: RenderPassEncoder,
    slot: u32, vertex_buffer: buffer.Buffer, offset: u64, size: u64) void;

extern fn wgpuRenderPassEncoderSetViewport(encoder: RenderPassEncoder,
    x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void;

extern fn wgpuRenderPassEncoderReference(encoder: RenderPassEncoder) void;

extern fn wgpuRenderPassEncoderRelease(encoder: RenderPassEncoder) void;
