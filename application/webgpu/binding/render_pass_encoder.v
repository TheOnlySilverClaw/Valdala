module binding

pub fn C.wgpuRenderPassEncoderEnd(encoder WGPURenderPassEncoder)

pub fn C.wgpuRenderPassEncoderSetPipeline(encoder WGPURenderPassEncoder, pipeline WGPURenderPipeline)

pub fn C.wgpuRenderPassEncoderSetBindGroup(encoder WGPURenderPassEncoder, index int, group WGPUBindGroup, dynamicOffsetCount int, dynamicOffsets &u32)

pub fn C.wgpuRenderPassEncoderSetVertexBuffer(encoder WGPURenderPassEncoder, slot u32, buffer WGPUBuffer, offset u64, size u64)

pub fn C.wgpuRenderPassEncoderDraw(encoder WGPURenderPassEncoder, vertexCount u32, instanceCount u32, firstVertex u32, firstInstance u32)

pub fn C.wgpuRenderPassEncoderRelease(encoder WGPURenderPassEncoder)
