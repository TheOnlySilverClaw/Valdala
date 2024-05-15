module binding

pub struct C.WGPUCommandEncoderDescriptor {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	label       &char
}

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

pub fn C.wgpuCommandEncoderBeginRenderPass(commandEncoder WGPUCommandEncoder, descriptor &C.WGPURenderPassDescriptor) WGPURenderPassEncoder

pub fn C.wgpuCommandEncoderFinish(encoder WGPUCommandEncoder, descriptor &C.WGPUCommandBufferDescriptor) WGPUCommandBuffer

pub fn C.wgpuCommandEncoderRelease(encoder WGPUCommandEncoder)
