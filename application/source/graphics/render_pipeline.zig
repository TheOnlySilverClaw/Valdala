const webgpu = @import("webgpu");
const Device = webgpu.device.Device;
const VertexBuffer = @import("vertex_buffer.zig").VertexBuffer;

pub const RenderPipeline = struct {

    block_sampler: webgpu.sampler.Sampler,

    pub fn create(device: Device) RenderPipeline {

        const block_sampler = createSampler(device, .repeat, .nearest);

        createRenderPipeline();

        const TypedVertexBuffer = VertexBuffer(Vertex, &.{.float32x3, .unorm16x2, .uint32});
        const vertex_buffer = TypedVertexBuffer.create(device, 4, null);
        const size: f32 = 0.5;
        const z : f32 = 0.5;
        const vertices: [4]Vertex = .{
            .{ .position = .{.x = -size, .y = size, .z = z }, .texture = .{.u = 0, .v = 0, .index = 0 }},
            .{ .position = .{.x = -size, .y = -size, .z = z }, .texture = .{.u = 0, .v = 1, .index = 0 }},
            .{ .position = .{.x = size, .y = -size, .z = z }, .texture = .{.u = 1, .v = 1, .index = 0 }},
            .{ .position = .{.x = size, .y = size, .z = z }, .texture = .{.u = 1, .v = 0, .index = 0 }},
        };
        vertex_buffer.upload(device.getQueue(), &vertices, 0);
        vertex_buffer.destroy();

        return .{
            .block_sampler = block_sampler
        };
    }
};

const Vertex = struct {
    position: struct {
        x: f32,
        y: f32,
        z: f32
    },
    texture: struct {
        u: u8,
        v: u8,
        index: u32
    }
};

fn createRenderPipeline() void {



}

fn createPipelineLayout(device: Device, bind_group_layouts: []const webgpu.bind_group_layout.BindGroupLayout) webgpu.pipeline_layout.PipelineLayout {

    const descriptor = webgpu.pipeline_layout.PipelineLayoutDescriptor {
        .bind_group_layout_count = bind_group_layouts.len,
        .bind_group_layouts = bind_group_layouts.ptr
    };

    return device.createPipelineLayout(&descriptor);
}


fn createSampler(device: Device,
    addressMode: webgpu.sampler.AddressMode,
    filter: webgpu.sampler.FilterMode) webgpu.sampler.Sampler {

	const descriptor = webgpu.sampler.SamplerDescriptor {
	    .address_mode_u  = addressMode,
	    .address_mode_v = addressMode,
	    .address_mode_w = addressMode,
	    .mag_filter = filter,
	    .min_filter = filter,
	    .mipmap_filter = filter,
    };
	
	return device.createSampler(&descriptor);
}

