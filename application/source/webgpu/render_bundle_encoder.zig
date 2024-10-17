const shared = @import("shared.zig");
const texture = @import("texture.zig");
const bundle = @import("render_bundle.zig");
const buffer = @import("buffer.zig");
const bind_group = @import("bind_group.zig");
const render_pipeline = @import("render_pipeline.zig");


pub const RenderBundleEncoder = *opaque {
    
    pub fn draw(encoder: RenderBundleEncoder,
        vertex_count: u32,instance_count: u32,first_vertex: u32, first_instance: u32) void {
        wgpuRenderBundleEncoderDraw(encoder,
            vertex_count, instance_count, first_vertex, first_instance);
    }

    pub fn drawIndexed(encoder: RenderBundleEncoder,
        index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        wgpuRenderBundleEncoderDrawIndexed(encoder,
            index_count, instance_count, first_index, base_vertex, first_instance);
    }

    pub fn drawIndexedIndirect(encoder: RenderBundleEncoder,
        indirect_buffer: buffer.Buffer, indirect_offset: u64) void {
        wgpuRenderBundleEncoderDrawIndexedIndirect(encoder, indirect_buffer, indirect_offset);
    }

    pub fn drawIndirect(encoder: RenderBundleEncoder,
        indirect_buffer: buffer.Buffer, indirect_offset: u64) void {
        wgpuRenderBundleEncoderDrawIndirect(encoder, indirect_buffer, indirect_offset);
    }

    pub fn finish(encoder: RenderBundleEncoder, descriptor: *bundle.RenderBundleDescriptor) bundle.RenderBundle {
        return wgpuRenderBundleEncoderFinish(encoder, descriptor);
    }

    pub fn insertDebugMarker(encoder: RenderBundleEncoder, label: [*:0]const u8) void {
        wgpuRenderBundleEncoderInsertDebugMarker(encoder, label);
    }

    pub fn popDebugGroup(encoder: RenderBundleEncoder) void {
        wgpuRenderBundleEncoderPopDebugGroup(encoder);
    }

    pub fn pushDebugGroup(encoder: RenderBundleEncoder, group_label: [*:0]const u8) void {
        wgpuRenderBundleEncoderPushDebugGroup(encoder, group_label);
    }

    pub fn setBindGroup(encoder: RenderBundleEncoder,
        index: u32, group: bind_group.BindGroup, dynamic_offsets: ?[]const u32) void {
        
        wgpuRenderBundleEncoderSetBindGroup(encoder,
            index, group,
            if (dynamic_offsets) |offsets| @as(u32, @intCast(offsets.len)) else 0,
            if (dynamic_offsets) |offsets| offsets.ptr else null,
        );
    }

    pub fn setIndexBuffer(encoder: RenderBundleEncoder,
        index_buffer: buffer.Buffer, format: buffer.IndexFormat, offset: u64, size: u64) void {
        wgpuRenderBundleEncoderSetIndexBuffer(encoder, index_buffer, format, offset, size);
    }

    pub fn setLabel(encoder: RenderBundleEncoder, label: ?[*:0]const u8) void {
        wgpuRenderBundleEncoderSetLabel(encoder, label);
    }

    pub fn setPipeline(encoder: RenderBundleEncoder, pipeline: render_pipeline.RenderPipeline) void {
        wgpuRenderBundleEncoderSetPipeline(encoder, pipeline);
    }

    pub fn setVertexBuffer(encoder: RenderBundleEncoder,
        slot: u32, vertex_buffer: buffer.Buffer, offset: u64, size: u64) void {
        wgpuRenderBundleEncoderSetVertexBuffer(encoder, slot, vertex_buffer, offset, size);
    }

    pub fn reference(encoder: RenderBundleEncoder) void {
        wgpuRenderBundleEncoderReference(encoder);
    }

    pub fn release(encoder: RenderBundleEncoder) void {
        wgpuRenderBundleEncoderRelease(encoder);
    }
};

pub const RenderBundleEncoderDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null,
    color_formats_count: usize,
    color_formats: ?[*]const texture.TextureFormat,
    depth_stencil_format: texture.TextureFormat,
    sample_count: u32,
    depth_read_only: bool,
    stencil_read_only: bool,
};


extern fn wgpuRenderBundleEncoderDraw(encoder: RenderBundleEncoder,
    vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void;

extern fn wgpuRenderBundleEncoderDrawIndexed(encoder: RenderBundleEncoder,
    index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void;

extern fn wgpuRenderBundleEncoderDrawIndexedIndirect(encoder: RenderBundleEncoder,
    indirect_buffer: buffer.Buffer, indirect_offset: u64) void;

extern fn wgpuRenderBundleEncoderDrawIndirect(encoder: RenderBundleEncoder,
    indirect_buffer: buffer.Buffer, indirect_offset: u64) void;

extern fn wgpuRenderBundleEncoderFinish(encoder: RenderBundleEncoder,
    descriptor: *const bundle.RenderBundleDescriptor) bundle.RenderBundle;

extern fn wgpuRenderBundleEncoderInsertDebugMarker(encoder: RenderBundleEncoder, label: [*:0]const u8) void;

extern fn wgpuRenderBundleEncoderPopDebugGroup(encoder: RenderBundleEncoder) void;

extern fn wgpuRenderBundleEncoderPushDebugGroup(encoder: RenderBundleEncoder, label: [*:0]const u8) void;

extern fn wgpuRenderBundleEncoderSetBindGroup(encoder: RenderBundleEncoder,
    index: u32, group: bind_group.BindGroup,
    dynamic_offset_count: u32, dynamic_offsets: ?[*]const u32) void;

extern fn wgpuRenderBundleEncoderSetIndexBuffer(encoder: RenderBundleEncoder,
    index_buffer: buffer.Buffer, format: buffer.IndexFormat, offset: u64, size: u64) void;

extern fn wgpuRenderBundleEncoderSetPipeline(encoder: RenderBundleEncoder, pipeline: render_pipeline.RenderPipeline) void;

extern fn wgpuRenderBundleEncoderSetLabel(encoder: RenderBundleEncoder, label: ?[*:0]const u8) void;

extern fn wgpuRenderBundleEncoderSetVertexBuffer(encoder: RenderBundleEncoder,
    slot: u32, vertex_buffer: buffer.Buffer, offset: u64, size: u64) void;

extern fn wgpuRenderBundleEncoderReference(encoder: RenderBundleEncoder) void;

extern fn wgpuRenderBundleEncoderRelease(encoder: RenderBundleEncoder) void;
