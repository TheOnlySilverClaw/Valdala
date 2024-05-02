module webgpu

#flag -I include
#flag -L libraries

#flag -l c
#flag -l m
#flag -l unwind
#flag -l wgpu_native

#include "wgpu.h"


type WGPUAdapter = voidptr
type WGPUBindGroup = voidptr
type WGPUBindGroupLayout = voidptr
type WGPUBuffer = voidptr
type WGPUCommandBuffer = voidptr
type WGPUCommandEncoder = voidptr
type WGPUComputePassEncoder = voidptr
type WGPUComputePipeline = voidptr
type WGPUDevice = voidptr
type WGPUInstance = voidptr
type WGPUPipelineLayout = voidptr
type WGPUQuerySet = voidptr
type WGPUQueue = voidptr
type WGPURenderBundle = voidptr
type WGPURenderBundleEncoder = voidptr
type WGPURenderPassEncoder = voidptr
type WGPURenderPipeline = voidptr
type WGPUSampler = voidptr
type WGPUShaderModule = voidptr
type WGPUSurface = voidptr
type WGPUTexture = voidptr
type WGPUTextureView = voidptr

struct C.WGPUChainedStruct {
	next &C.WGPUChainedStruct = unsafe { nil }
}

struct C.WGPUInstanceDescriptor {
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
}


fn C.wgpuGetVersion() int

fn C.wgpuCreateInstance(descriptor &C.WGPUInstanceDescriptor) WGPUInstance

fn C.wgpuInstanceRelease(instance WGPUInstance)