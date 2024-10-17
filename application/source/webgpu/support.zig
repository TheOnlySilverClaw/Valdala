const shared = @import("shared.zig");

pub const FeatureName = enum(u32) {
    undefined,
    depth_clip_control,
    depth32_float_stencil8,
    timestamp_query,
    pipeline_statistics_query,
    texture_compression_bc,
    texture_compression_etc2,
    texture_compression_astc,
    indirect_first_instance,
    shader_f16,
    rg11_b10_ufloat_renderable,
    bgra8_unorm_storage,
    float32_filterable
};

pub const Limits = extern struct {
    const u32_undefined: u32 = 0xFFFFFFFF;
    const u64_undefined: u64 = 0xFFFFFFFFFFFFFFFF;

    max_texture_dimension_1d: u32 = u32_undefined,
    max_texture_dimension_2d: u32 = u32_undefined,
    max_texture_dimension_3d: u32 = u32_undefined,
    max_texture_array_layers: u32 = u32_undefined,
    max_bind_groups: u32 = u32_undefined,
    max_bind_groups_plus_vertex_buffers: u32 = u32_undefined,
    max_bindings_per_bind_group: u32 = u32_undefined,
    max_dynamic_uniform_buffers_per_pipeline_layout: u32 = u32_undefined,
    max_dynamic_storage_buffers_per_pipeline_layout: u32 = u32_undefined,
    max_sampled_textures_per_shader_stage: u32 = u32_undefined,
    max_samplers_per_shader_stage: u32 = u32_undefined,
    max_storage_buffers_per_shader_stage: u32 = u32_undefined,
    max_storage_textures_per_shader_stage: u32 = u32_undefined,
    max_uniform_buffers_per_shader_stage: u32 = u32_undefined,
    max_uniform_buffer_binding_size: u64 = u64_undefined,
    max_storage_buffer_binding_size: u64 = u64_undefined,
    min_uniform_buffer_offset_alignment: u32 = u32_undefined,
    min_storage_buffer_offset_alignment: u32 = u32_undefined,
    max_vertex_buffers: u32 = u32_undefined,
    max_buffer_size: u64 = u64_undefined,
    max_vertex_attributes: u32 = u32_undefined,
    max_vertex_buffer_array_stride: u32 = u32_undefined,
    max_inter_stage_shader_components: u32 = u32_undefined,
    max_inter_stage_shader_variables: u32 = u32_undefined,
    max_color_attachments: u32 = u32_undefined,
    max_color_attachment_bytes_per_sample: u32 = u32_undefined,
    max_compute_workgroup_storage_size: u32 = u32_undefined,
    max_compute_invocations_per_workgroup: u32 = u32_undefined,
    max_compute_workgroup_size_x: u32 = u32_undefined,
    max_compute_workgroup_size_y: u32 = u32_undefined,
    max_compute_workgroup_size_z: u32 = u32_undefined,
    max_compute_workgroups_per_dimension: u32 = u32_undefined
};


pub const RequiredLimits = extern struct {
    next: ?*const shared.ChainedStruct = null,
    limits: Limits = .{},
};

pub const SupportedLimits = extern struct {
    next: ?*shared.ChainedStructOut = null,
    limits: Limits = .{},
};