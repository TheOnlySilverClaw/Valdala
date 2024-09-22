module graphics;

import webgpu;

struct Renderer {
    Color clearColor;
    RenderPipeline pipeline;
}

fn void! Renderer.init(&self, Device device, TextureFormat colorTextureFormat, Allocator allocator) {

    BindGroupLayout[1] bindGroupLayouts;
    bindGroupLayouts[0] = createBindGroupLayout(device);

    PipelineLayout pipelineLayout = createPipelineLayout(device, &bindGroupLayouts);

    ShaderModule shaderModule = loadShaderModule("shaders/textured.wgsl", device, allocator)!;

    RenderPipeline renderPipeline = createRenderPipeline(
        device, pipelineLayout, shaderModule, colorTextureFormat);
    self.pipeline = renderPipeline;
}


fn BindGroupLayout createBindGroupLayout(Device device) {

    BindGroupLayoutEntry projectionBufferEntry;
    projectionBufferEntry.visibility = { .vertex = true };
    projectionBufferEntry.buffer.type = UNIFORM;

    BindGroupLayoutEntry samplerEntry;
    samplerEntry.visibility = { .fragment = true };
    samplerEntry.sampler.type = FILTERING;

    BindGroupLayoutEntry textureEntry;
    textureEntry.visibility = { .fragment = true };
    textureEntry.texture.sampleType = FLOAT;
    textureEntry.texture.viewDimension = SINGLE_2D;
    textureEntry.texture.multisampled = 0;

    BindGroupLayoutEntry[*] entries = {
        projectionBufferEntry,
        samplerEntry,
        textureEntry
    };

    for (int i = 0; i < entries.len; i++) {
        entries[i].binding = i;
    }

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
    VertexAttribute positionAttribute;
    positionAttribute.format = FLOAT_32X3;
    positionAttribute.offset = 0;

    // TODO compute from struct?
    VertexAttribute uvAttribute;
    uvAttribute.format = FLOAT_32X2;
    positionAttribute.offset = float.sizeof * 3;

    VertexAttribute textureIndexAttribute;
    // TODO compute from struct?
    textureIndexAttribute.format = FLOAT_32;
    positionAttribute.offset = float.sizeof * (3 + 2);

    VertexAttribute[*] vertexAttributes = {
        positionAttribute,
        uvAttribute,
        textureIndexAttribute
    };

    for(int i = 0; i < vertexAttributes.len; i++) {
        vertexAttributes[i].shaderLocation = i;
    }

    VertexBufferLayout vertexBuffer;
    // TODO compute from struct? with alignment padding!
    vertexBuffer.arrayStride = 8;
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
    descriptor.multisample.mask = ~0u;

    ColorTargetState colorTarget;
    colorTarget.format = colorTextureFormat;
    colorTarget.blend = null;
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
    Texture colorTexture, Device device, webgpu::Surface surface) {

    TextureView colorTextureView = colorTexture.createView();

    CommandEncoder commandEncoder = device.createCommandEncoder();

    Queue queue = device.getQueue();

    RenderPassColorAttachment colorAttachment;
    colorAttachment.view = colorTextureView;
    colorAttachment.loadOperation = CLEAR;
    colorAttachment.storeOperation = STORE;
    colorAttachment.clearValue = self.clearColor;

    RenderPassDescriptor renderPassDescriptor;
    renderPassDescriptor.colorAttachmentCount = 1;
    renderPassDescriptor.colorAttachments = &colorAttachment;

    RenderPassEncoder renderPassEncoder = commandEncoder.beginRenderPass(&renderPassDescriptor);
    renderPassEncoder.end();
    renderPassEncoder.release();

    CommandBuffer commandBuffer = commandEncoder.finish();

    queue.submit(1, &commandBuffer);

    colorTextureView.release();
    commandEncoder.release();
    commandBuffer.release();
    queue.release();

    surface.present();
}

fn void Renderer.destroy(&self) {
}
