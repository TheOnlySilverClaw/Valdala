module graphics;

import webgpu;
import asset;
import std::io;
import std::math::matrix;

struct Renderer {
    Color clearColor;
    RenderPipeline pipeline;
    BindGroup bindGroup;
    Buffer projectionBuffer;
	Buffer vertexBuffer;
}

fn void! Renderer.init(&self, Device device, Queue queue, TextureFormat colorTextureFormat, TextureFormat depthTextureFormat, Allocator allocator) {

    BindGroupLayout bindGroupLayout = createBindGroupLayout(device);
    BindGroupLayout[] bindGroupLayouts = { bindGroupLayout };

    PipelineLayout pipelineLayout = createPipelineLayout(device, bindGroupLayouts);

    ShaderModule shaderModule = loadShaderModule("shaders/textured.wgsl", device, allocator)!;

	
	float[] vertices = square(0.5, allocator);
    defer allocator::free(allocator, vertices);
	
	
	usz bufferSize = vertices.len * float.sizeof;

    Path texturesRoot = path::new("textures", allocator)!;
    defer texturesRoot.free_with_allocator(allocator);

    TextureLoader textureLoader = {
        .allocator = allocator,
        .root = texturesRoot,
        .device = device,
        .queue = queue
    };

	TextureView texture = textureLoader.loadTextureArray(
        colorTextureFormat, 16, 16,
        "testing/texture_1.qoi",
        "testing/texture_2.qoi",
        "testing/texture_3.qoi",
        "testing/texture_4.qoi"
    )!;
	
    self.pipeline = createRenderPipeline(
        device, pipelineLayout, shaderModule, colorTextureFormat, depthTextureFormat);
	self.vertexBuffer = createVertexBuffer(device, bufferSize);
    self.projectionBuffer = createProjectionBuffer(device);
	Sampler sampler = createSampler(device, REPEAT, NEAREST, LINEAR);
	self.bindGroup = createBindGroup(device, bindGroupLayout, self.projectionBuffer, sampler, texture);
	
	queue.writeBuffer(self.vertexBuffer, 0, vertices.ptr, bufferSize);
		
}

fn Buffer createProjectionBuffer(Device device) {
    
    BufferDescriptor descriptor = {
        .label = "projection",
        .usage = { .copyDestination = true, .uniform = true },
        .size = 4 * 4 * float.sizeof
    };

    return device.createBuffer(&descriptor);
}

fn BindGroup createBindGroup(Device device, BindGroupLayout layout, Buffer projectionBuffer, Sampler sampler, TextureView texture) {

    BindGroupEntry projectionBufferEntry = {
        .binding = 0,
        .buffer = projectionBuffer,
        .size = projectionBuffer.getSize()
    };

	BindGroupEntry samplerEntry = {
		.binding = 1,
		.sampler = sampler
	};
	
	BindGroupEntry textureEntry = {
		.binding = 2,
		.textureView = texture
	};
	
	BindGroupEntry[*] entries = {
        projectionBufferEntry,
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


fn Sampler createSampler(Device device, AddressMode addressMode, FilterMode filterMode, MipmapFilterMode mipmapFilterMode) {

	SamplerDescriptor descriptor = {
	    .addressModeU = addressMode,
	    .addressModeV = addressMode,
	    .addressModeW = addressMode,
	    .magFilter = filterMode,
	    .minFilter = filterMode,
	    .mipmapFilter = mipmapFilterMode,
	    .maxAnisotropy = 1
    };
	
	return device.createSampler(&descriptor);
}

fn Buffer createVertexBuffer(Device device, usz size) {

	BufferDescriptor descriptor = {
		.label = "vertex",
		.usage = { .vertex = true, .copyDestination = true },
		.size = size,
	};
	
	return device.createBuffer(&descriptor);
}

fn BindGroupLayout createBindGroupLayout(Device device) {

    BindGroupLayoutEntry projectionBufferEntry;
    projectionBufferEntry.binding = 0;
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
    textureEntry.texture.viewDimension = ARRAY_2D;
    textureEntry.texture.multisampled = 0;

    BindGroupLayoutEntry[*] entries = {
        projectionBufferEntry,
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
    PipelineLayout pipelineLayout, ShaderModule shaderModule, TextureFormat colorTextureFormat, TextureFormat depthTextureFormat) {


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


    // TODO compute from struct? with alignment padding!
    VertexBufferLayout vertexBufferLayout = {
        .arrayStride = (3+2+1) * float.sizeof,
        .stepMode = VERTEX,
        .attributeCount = vertexAttributes.len,
        .attributes = &vertexAttributes
    };

    VertexState vertexState = {
        .shaderModule = shaderModule,
        .entryPoint = "vertex",
        .bufferCount = 1,
        .buffers = &vertexBufferLayout
    };

    PrimitiveState primitiveState = {
        .topology = TRIANGLE_LIST,
        .frontFace = COUNTER_CLOCKWISE,
        // TODO change to FRONT when rendering works
        .cullMode = NONE
    };

    DepthStencilState depthStencilState = {
        .format = depthTextureFormat,
        .depthWriteEnabled = 1,
        .depthCompare = LESS,
        .stencilFront = {
            .compare = ALWAYS,
            .failOperation = KEEP,
            .depthFailOperation = KEEP,
            .passOperation = KEEP
        },
        .stencilBack = {
            .compare = ALWAYS,
            .failOperation = KEEP,
            .depthFailOperation = KEEP,
            .passOperation = KEEP
        }
    };

    MultisampleState multisampleState = {
        .count = 1,
        .mask = webgpu::UNDEFINED
    };

	BlendState blendState = {
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
	
    ColorTargetState colorTargetState = {
        .format = colorTextureFormat,
        .blend = &blendState,
        .writeMask = {
            .red = true,
            .green = true,
            .blue = true,
            .alpha = true }
    };

    FragmentState fragmentState = {
        .shaderModule = shaderModule,
        .entryPoint = "fragment",
        .targetCount = 1,
        .targets = &colorTargetState
    };

    RenderPipelineDescriptor descriptor = {
        .label = "textured mesh",
        .layout = pipelineLayout,
        .vertex = vertexState,
        .primitive = primitiveState,
        .depthStencil = &depthStencilState,
        .multisample = multisampleState,
        .fragment = &fragmentState
    };


    return device.createRenderPipeline(&descriptor);
}


fn void Renderer.render(&self,
    Texture colorTexture, Texture depthTexture, Device device, Queue queue, Matrix4 projection) {

    queue.writeBuffer(self.projectionBuffer, 0, &projection, self.projectionBuffer.getSize());

    TextureView colorTextureView = colorTexture.createView();
    TextureView depthTextureView = depthTexture.createView();

    CommandEncoder commandEncoder = device.createCommandEncoder();

    RenderPassColorAttachment colorAttachment;
    colorAttachment.view = colorTextureView;
    colorAttachment.loadOperation = CLEAR;
    colorAttachment.storeOperation = STORE;
    colorAttachment.clearValue = self.clearColor;

    RenderPassDepthStencilAttachment depthStencilAttachment = {
        .view = depthTextureView,
        .depthLoadOperation = CLEAR,
        .depthStoreOperation = STORE,
        .depthClearValue = 1.0,
        .depthReadOnly = 0
    };

    RenderPassDescriptor renderPassDescriptor = {
        .colorAttachmentCount = 1,
        .colorAttachments = &colorAttachment,
        .depthStencilAttachment = &depthStencilAttachment
    };

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
}

fn void Renderer.destroy(&self) {
}
