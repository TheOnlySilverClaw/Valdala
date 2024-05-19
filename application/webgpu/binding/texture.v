module binding

pub fn C.wgpuTextureCreateView(texture WGPUTexture, descriptor &C.WGPUTextureViewDescriptor) WGPUTextureView

pub fn C.wgpuTextureRelease(texture WGPUTexture)

pub fn C.wgpuTextureViewRelease(view WGPUTextureView)

pub struct C.WGPUTextureDescriptor {
pub:
	nextInChain     &C.WGPUChainedStruct = unsafe { nil }
	label           &char
	usage           WGPUTextureUsage
	dimension       WGPUTextureDimension
	size            C.WGPUExtent3D
	format          WGPUTextureFormat
	mipLevelCount   u32
	sampleCount     u32
	viewFormatCount usize
	viewFormats     &WGPUTextureFormat
}

pub struct C.WGPUExtent3D {
pub:
	width              u32
	height             u32
	depthOrArrayLayers u32
}

pub struct C.WGPUTextureViewDescriptor {
pub:
	nextInChain     &C.WGPUChainedStruct = unsafe { nil }
	label           &char
	format          WGPUTextureFormat
	dimension       WGPUTextureViewDimension
	baseMipLevel    u32
	mipLevelCount   u32
	baseArrayLayer  u32
	arrayLayerCount u32
	aspect          WGPUTextureAspect
}

pub struct C.WGPUImageCopyTexture {
pub:
	nextInChain &C.WGPUChainedStruct = unsafe { nil }
	texture     WGPUTexture
	mipLevel    u32
	origin      C.WGPUOrigin3D
	aspect      WGPUTextureAspect
}

pub struct C.WGPUOrigin3D {
pub:
	x u32
	y u32
	z u32
}

pub struct C.WGPUTextureDataLayout {
pub:
	nextInChain  &C.WGPUChainedStruct = unsafe { nil }
	offset       u64
	bytesPerRow  u32
	rowsPerImage u32
}

pub enum WGPUTextureFormat {
	undefined              = 0
	r8_unorm               = 1
	r8_snorm               = 2
	r8_uint                = 3
	r8_sint                = 4
	r16_uint               = 5
	r16_sint               = 6
	r16_float              = 7
	rg8_unorm              = 8
	rg8_snorm              = 9
	rg8_uint               = 10
	rg8_sint               = 11
	r32_float              = 12
	r32_uint               = 13
	r32_sint               = 14
	rg16_uint              = 15
	rg16_sint              = 16
	rg16_float             = 17
	rgba8_unorm            = 18
	rgba8_unorm_srgb       = 19
	rgba8_snorm            = 20
	rgba8_uint             = 21
	rgba8_sint             = 22
	bgra8_unorm            = 23
	bgra8_unorm_srgb       = 24
	rgb10_a2_uint          = 25
	rgb10_a2_unorm         = 26
	rg11_b10_ufloat        = 27
	rgb9_e5_ufloat         = 28
	rg32_float             = 29
	rg32_uint              = 30
	rg32_sint              = 31
	rgba16_uint            = 32
	rgba16_sint            = 33
	rgba16_float           = 34
	rgba32_float           = 35
	rgba32_uint            = 36
	rgba32_sint            = 37
	stencil8               = 38
	depth16_unorm          = 39
	depth24_plus           = 40
	depth24_plus_stencil8  = 41
	depth32_float          = 42
	depth32_float_stencil8 = 43
	bc1_rgba_unorm         = 44
	bc1_rgba_unorm_srgb    = 45
	bc2_rgba_unorm         = 46
	bc2_rgba_unorm_srgb    = 47
	bc3_rgba_unorm         = 48
	bc3_rgba_unorm_srgb    = 49
	bc4r_unorm             = 50
	bc4r_snorm             = 51
	bc5rg_unorm            = 52
	bc5rg_snorm            = 53
	bc6h_rgb_ufloat        = 54
	bc6h_rgb_float         = 55
	bc7_rgba_unorm         = 56
	bc7_rgba_unorm_srgb    = 57
	etc2_rgb8_unorm        = 58
	etc2_rgb8_unorm_srgb   = 59
	etc2_rgb8a1_unorm      = 60
	etc2_rgb8a1_unorm_srgb = 61
	etc2_rgba8_unorm       = 62
	etc2_rgba8_unorm_srgb  = 63
	eacr11_unorm           = 64
	eacr11_snorm           = 65
	eacrg11_unorm          = 66
	eacrg11_snorm          = 67
	astc4x4_unorm          = 68
	astc4x4_unorm_srgb     = 69
	astc5x4_unorm          = 70
	astc5x4_unorm_srgb     = 71
	astc5x5_unorm          = 72
	astc5x5_unorm_srgb     = 73
	astc6x5_unorm          = 74
	astc6x5_unorm_srgb     = 75
	astc6x6_unorm          = 76
	astc6x6_unorm_srgb     = 77
	astc8x5_unorm          = 78
	astc8x5_unorm_srgb     = 79
	astc8x6_unorm          = 80
	astc8x6_unorm_srgb     = 81
	astc8x8_unorm          = 82
	astc8x8_unorm_srgb     = 83
	astc10x5_unorm         = 84
	astc10x5_unorm_srgb    = 85
	astc10x6_unorm         = 86
	astc10x6_unorm_srgb    = 87
	astc10x8_unorm         = 88
	astc10x8_unorm_srgb    = 89
	astc10x10_unorm        = 90
	astc10x10_unorm_srgb   = 91
	astc12x10_unorm        = 92
	astc12x10_unorm_srgb   = 93
	astc12x12_unorm        = 94
	astc12x12_unorm_srgb   = 95
}

@[flag]
pub enum WGPUTextureUsage {
	copy_src
	copy_dst
	texture_binding
	storage_binding
	render_attachment
}

pub enum WGPUTextureDimension {
	_1d = 0
	_2d = 1
	_3d = 2
}

pub enum WGPUTextureViewDimension {
	undefined  = 0
	_1d        = 1
	_2d        = 2
	array_2d   = 3
	cube       = 4
	array_cube = 5
	single_3d  = 6
}

pub enum WGPUTextureAspect {
	all          = 0
	stencil_only = 1
	depth_only   = 2
}
