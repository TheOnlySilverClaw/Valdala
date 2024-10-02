module graphics;

import webgpu;
import asset;
import std::io;

struct Renderer {
    Color clearColor;
    RenderPipeline pipeline;
    BindGroup bindGroup;
	Buffer vertexBuffer;
}

fn void! Renderer.init(&self, Device device, Queue queue, TextureFormat colorTextureFormat, Allocator allocator) {

    BindGroupLayout bindGroupLayout = createBindGroupLayout(device);
    BindGroupLayout[] bindGroupLayouts = { bindGroupLayout };

    PipelineLayout pipelineLayout = createPipelineLayout(device, bindGroupLayouts);

    ShaderModule shaderModule = loadShaderModule("shaders/textured.wgsl", device, allocator)!;

	
	float size = 0.5;
	
	float[] vertices = {
		// x	y		z		u  v  texture index
		-size,	size,	0.5,	0, 0, 0,
		-size, -size,	0.5,	0, 1, 0,
		size, -size,	0.5,	1, 1, 0,

		size, -size,	0.5,	1, 1, 0,
		size, size,		0.5,	1, 0, 0,
		-size, size,	0.5,	0, 0, 0,
	};
	
	
	usz bufferSize = vertices.len * float.sizeof;

    Image image;
    defer image.free();
    image.loadQOI("textures/testing/texture_1.qoi", allocator)!;
    
	Texture texture = createTexture(device, image, colorTextureFormat, allocator)!;
	
	TextureViewDescriptor viewDescriptor = {
		.format = colorTextureFormat,
		.dimension = SINGLE_2D,
		.baseMipLevel = 0,
		.mipLevelCount = 1,
		.baseArrayLayer = 0,
		.arrayLayerCount = 1,
		.aspect = ALL
	};
	
	TextureView textureView = texture.createView(&viewDescriptor);
	
    self.pipeline = createRenderPipeline(
        device, pipelineLayout, shaderModule, colorTextureFormat);
	self.vertexBuffer = createVertexBuffer(device, bufferSize);
	Sampler sampler = createSampler(device, REPEAT, NEAREST, LINEAR);
	self.bindGroup = createBindGroup(device, bindGroupLayout, sampler, textureView);
	
	queue.writeBuffer(self.vertexBuffer, 0, vertices.ptr, bufferSize);
    
	ImageCopyTexture textureDestination = {
		.texture = texture,
		.mipLevel = 0,
		.origin = {},
		.aspect = ALL
	};
	
	TextureDataLayout textureLayout = {
		.offset = 0,
		.bytesPerRow = image.width * 4,
		.rowsPerImage = image.height
	};
	
	Extent3D textureSize = {
		.width = image.width,
		.height = image.height,
		.depthOrArrayLayers = 1
	};
	
	queue.writeTexture(&textureDestination, image.pixels.ptr, image.pixels.len, &textureLayout, &textureSize);
		
}

fn BindGroup createBindGroup(Device device, BindGroupLayout layout, Sampler sampler, TextureView texture) {

	BindGroupEntry samplerEntry = {
		.binding = 1,
		.sampler = sampler
	};
	
	BindGroupEntry textureEntry = {
		.binding = 2,
		.textureView = texture
	};
	
	BindGroupEntry[*] entries = {
		samplerEntry,
		textureEntry
	};
	
	BindGroupDescriptor descriptor = {
		.layout = layout,
		.entryCount = entries.len,
		.entries = &entries
	};
	
	return device.createBindGroup(&descriptor);
}

fn Texture! createTexture(Device device, Image image, TextureFormat format, Allocator allocator) {

    
    TextureDescriptor textureDescriptor;
    textureDescriptor.label = "texture_1";
    textureDescriptor.usage = { .textureBinding = true, .copyDestination = true };
    textureDescriptor.dimension = DIMENSION_2D;
    textureDescriptor.size.width = image.width;
    textureDescriptor.size.height = image.height;
    textureDescriptor.size.depthOrArrayLayers = 1;
    textureDescriptor.format = format;
    textureDescriptor.mipLevelCount = 1;
    textureDescriptor.sampleCount = 1;
    
    Texture texture = device.createTexture(&textureDescriptor);
    return texture;
}

fn Sampler createSampler(Device device, AddressMode addressMode, FilterMode filterMode, MipmapFilterMode mipmapFilterMode) {

	SamplerDescriptor descriptor;
	descriptor.addressModeU = addressMode;
	descriptor.addressModeV = addressMode;
	descriptor.addressModeW = addressMode;
	descriptor.magFilter = filterMode;
	descriptor.minFilter = filterMode;
	descriptor.mipmapFilter = mipmapFilterMode;
	descriptor.maxAnisotropy = 1;
	
	return device.createSampler(&descriptor);
}

fn Buffer createVertexBuffer(Device device, usz size) {

	BufferDescriptor descriptor = {
		.label = "vertex",
		.usage = { .vertex = true, .copyDestination = true },
		.size = size,
		.mappedAtCreation = 0
	};
	
	return device.createBuffer(&descriptor);
}

fn BindGroupLayout createBindGroupLayout(Device device) {

    BindGroupLayoutEntry projectionBufferEntry;
    projectionBufferEntry.visibility = { .vertex = true };
    projectionBufferEntry.buffer.type = UNIFORM;

    BindGroupLayoutEntry samplerEntry;
    samplerEntry.binding = 1;
    samplerEntry.visibility = { .fragment = true };
    samplerEntry.sampler.type = FILTERING;

    BindGroupLayoutEntry textureEntry;
    textureEntry.binding = 2;
    textureEntry.visibility = { .fragment = true };
    textureEntry.texture.sampleType = FLOAT;
    textureEntry.texture.viewDimension = SINGLE_2D;
    textureEntry.texture.multisampled = 0;

    BindGroupLayoutEntry[*] entries = {
        // projectionBufferEntry,
        samplerEntry,
        textureEntry
    };


    BindGroupLayoutDescriptor descriptor;
    descriptor.entryCount = entries.len;
    descriptor.entries = &entries;

    return device.createBindGroupLayout(&descriptor);
}

fn PipelineLayout createPipelineLayout(Device device, BindGroupLayout[] bindGroupLayouts) {

    PipelineLayoutDescriptor descriptor;
    descriptor.bindGroupLayoutCount = bindGroupLayouts.len;
    descriptor.bindGroupLayouts = bindGroupLayouts.ptr;

    return device.createPipelineLayout(&descriptor);
}

fn RenderPipeline createRenderPipeline(Device device,
    PipelineLayout pipelineLayout, ShaderModule shaderModule, TextureFormat colorTextureFormat) {

    RenderPipelineDescriptor descriptor;
    descriptor.label = "textured mesh";
    descriptor.layout = pipelineLayout;

    // TODO compute from struct?
    VertexAttribute positionAttribute = {
	    .shaderLocation = 0,
    	.format = FLOAT_32X2,
	    .offset = 0
    };

    VertexAttribute uvAttribute = {
    	.shaderLocation = 1,
    	.format = FLOAT_32X2,
    	.offset = float.sizeof * 3
    };

    VertexAttribute textureIndexAttribute = {
		.shaderLocation = 2,
    	.format = FLOAT_32,
    	.offset = float.sizeof * (3 + 2)
    };

    VertexAttribute[*] vertexAttributes = {
        positionAttribute,
        uvAttribute,
        textureIndexAttribute
    };


    VertexBufferLayout vertexBuffer;
    // TODO compute from struct? with alignment padding!
    vertexBuffer.arrayStride = (3+2+1) * float.sizeof;
    vertexBuffer.stepMode = VERTEX;
    vertexBuffer.attributeCount = vertexAttributes.len;
    vertexBuffer.attributes = &vertexAttributes;

    descriptor.vertex.shaderModule = shaderModule;
    descriptor.vertex.entryPoint = "vertex";
    descriptor.vertex.bufferCount = 1;
    descriptor.vertex.buffers = &vertexBuffer;

    descriptor.primitive.topology = TRIANGLE_LIST;
    descriptor.primitive.frontFace = COUNTER_CLOCKWISE;
    // TODO change to FRONT when rendering works
    descriptor.primitive.cullMode = NONE;

    descriptor.depthStencil = null;

    descriptor.multisample.count = 1;
    descriptor.multisample.mask = webgpu::UNDEFINED;

	BlendState blend = {
		.color = {
			.operation = ADD,
			.sourceFactor = SRC_ALPHA,
			.destinationFactor = ONE_MINUS_SRC_ALPHA
		},
		.alpha = {
			.operation = ADD,
			.sourceFactor = ZERO,
			.destinationFactor = ONE
		}
	};
	
    ColorTargetState colorTarget;
    colorTarget.format = colorTextureFormat;
    colorTarget.blend = &blend;
    colorTarget.writeMask = { .red = true, .green = true, .blue = true, .alpha = true };

    FragmentState fragment;
    fragment.shaderModule = shaderModule;
    fragment.entryPoint = "fragment";
    fragment.targetCount = 1;
    fragment.targets = &colorTarget;
    descriptor.fragment = &fragment;

    return device.createRenderPipeline(&descriptor);
}


fn void Renderer.render(&self,
    Texture colorTexture, Device device, Queue queue, webgpu::Surface surface) {

    TextureView colorTextureView = colorTexture.createView();

    CommandEncoder commandEncoder = device.createCommandEncoder();

    RenderPassColorAttachment colorAttachment;
    colorAttachment.view = colorTextureView;
    colorAttachment.loadOperation = CLEAR;
    colorAttachment.storeOperation = STORE;
    colorAttachment.clearValue = self.clearColor;

    RenderPassDescriptor renderPassDescriptor;
    renderPassDescriptor.colorAttachmentCount = 1;
    renderPassDescriptor.colorAttachments = &colorAttachment;

    RenderPassEncoder renderPassEncoder = commandEncoder.beginRenderPass(&renderPassDescriptor);
    
    renderPassEncoder.setPipeline(self.pipeline);
    renderPassEncoder.setVertexBuffer(0, self.vertexBuffer, 0, self.vertexBuffer.getSize());
    renderPassEncoder.setBindGroup(0, self.bindGroup);
    
    renderPassEncoder.draw(6, 1, 0, 0);
    
    renderPassEncoder.end();
    renderPassEncoder.release();
    colorTextureView.release();


    CommandBuffer commandBuffer = commandEncoder.finish();
    commandEncoder.release();
    

    queue.submit(1, &commandBuffer);
    commandBuffer.release();
    
    surface.present();
}

fn void Renderer.destroy(&self) {
}
