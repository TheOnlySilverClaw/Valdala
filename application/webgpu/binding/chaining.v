module binding

pub struct C.WGPUChainedStruct {
pub:
	next  &C.WGPUChainedStruct
	sType WGPUSType
}

pub struct C.WGPUChainedStructOut {
pub:
	next  &C.WGPUChainedStructOut
	sType WGPUSType
}
