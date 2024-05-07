module binding

pub type Size_t = u32
pub type Wchar_t = int
pub type WGPUFlags = u32
pub type WGPUBool = u32

// adapter
pub type WGPUAdapter = voidptr

// bind_group
pub type WGPUBindGroup = voidptr
pub type WGPUBindGroupLayout = voidptr

// buffer
pub type WGPUBuffer = voidptr

// compute
pub type WGPUCommandBuffer = voidptr
pub type WGPUCommandEncoder = voidptr
pub type WGPUComputePassEncoder = voidptr
pub type WGPUComputePipeline = voidptr


// device
pub type WGPUDevice = voidptr

// instance
pub type WGPUInstance = voidptr

// pipeline
pub type WGPUPipelineLayout = voidptr
pub type WGPUQuerySet = voidptr

// queue
pub type WGPUQueue = voidptr

// render_bundle
pub type WGPURenderBundle = voidptr
pub type WGPURenderBundleEncoder = voidptr

// render
pub type WGPURenderPassEncoder = voidptr
pub type WGPURenderPipeline = voidptr
pub type WGPUSampler = voidptr

// shader
pub type WGPUShaderModule = voidptr

// surface
pub type WGPUSurface = voidptr

// texture
pub type WGPUTexture = voidptr
pub type WGPUTextureView = voidptr