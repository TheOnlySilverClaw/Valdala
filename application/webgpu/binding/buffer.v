module binding

pub struct C.WGPUBufferDescriptor {
pub:
	nextInChain      &C.WGPUChainedStruct = unsafe { nil }
	label            &char
	usage            WGPUBufferUsage
	size             u64
	mappedAtCreation WGPUBool
}

@[flag]
pub enum WGPUBufferUsage {
	map_read
	map_write
	copy_src
	copy_dst
	index
	vertex
	uniform
	storage
	indirect
	query_resolve
}

pub fn C.wgpuBufferGetSize(buffer WGPUBuffer) u64

pub fn C.wgpuBufferUnmap(buffer WGPUBuffer)

pub fn C.wgpuBufferDestroy(buffer WGPUBuffer)
