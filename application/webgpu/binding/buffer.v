module binding

pub struct C.WGPUBufferDescriptor {
pub:
	nextInChain      &C.WGPUChainedStruct = unsafe { nil }
	label            &char
	usage            WGPUFlags
	size             u64
	mappedAtCreation WGPUBool
}

pub fn C.wgpuBufferGetSize(buffer WGPUBuffer) u64

pub fn C.wgpuBufferUnmap(buffer WGPUBuffer)

pub fn C.wgpuBufferDestroy(buffer WGPUBuffer)
