module binding

pub struct C.WGPURenderPassDescriptor {
pub:
	nextInChain            &C.WGPUChainedStruct = unsafe { nil }
	label                  &char
	colorAttachmentCount   usize
	colorAttachments       &C.WGPURenderPassColorAttachment
	depthStencilAttachment &C.WGPURenderPassDepthStencilAttachment
	occlusionQuerySet      WGPUQuerySet
	timestampWrites        &C.WGPURenderPassTimestampWrites
}

pub struct C.WGPURenderPassColorAttachment {
pub:
	nextInChain   &C.WGPUChainedStruct = unsafe { nil }
	view          WGPUTextureView
	resolveTarget WGPUTextureView
	loadOp        WGPULoadOp
	storeOp       WGPUStoreOp
	clearValue    C.WGPUColor
}

pub struct C.WGPUColor {
pub:
	r f64
	g f64
	b f64
	a f64
}

pub struct C.WGPURenderPassDepthStencilAttachment {
pub:
	view              WGPUTextureView
	depthLoadOp       WGPULoadOp
	depthStoreOp      WGPUStoreOp
	depthClearValue   f32
	depthReadOnly     WGPUBool
	stencilLoadOp     WGPULoadOp
	stencilStoreOp    WGPUStoreOp
	stencilClearValue u32
	stencilReadOnly   WGPUBool
}

pub struct C.WGPURenderPassTimestampWrites {
pub:
	querySet                  WGPUQuerySet
	beginningOfPassWriteIndex u32
	endOfPassWriteIndex       u32
}

pub enum WGPULoadOp {
	undefined = 0
	clear     = 1
	load      = 2
	// force32   = 0x7FFFFFFF
}

pub enum WGPUStoreOp {
	undefined = 0
	store     = 1
	discard   = 2
	// force32   = 0x7FFFFFFF
}

pub fn C.wgpuRenderPassEncoderEnd(encoder WGPURenderPassEncoder)

pub fn C.wgpuRenderPassEncoderSetPipeline(encoder WGPURenderPassEncoder, pipeline WGPURenderPipeline)

pub fn C.wgpuRenderPassEncoderSetBindGroup(encoder WGPURenderPassEncoder, index int, group WGPUBindGroup, dynamicOffsetCount int, dynamicOffsets &u32)

pub fn C.wgpuRenderPassEncoderSetVertexBuffer(encoder WGPURenderPassEncoder, slot u32, buffer WGPUBuffer, offset u64, size u64)

pub fn C.wgpuRenderPassEncoderDraw(encoder WGPURenderPassEncoder, vertexCount u32, instanceCount u32, firstVertex u32, firstInstance u32)

pub fn C.wgpuRenderPassEncoderRelease(encoder WGPURenderPassEncoder)
