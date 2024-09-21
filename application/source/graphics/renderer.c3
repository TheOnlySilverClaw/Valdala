module graphics;

import webgpu;

struct Renderer {
    Color clearColor;
}

fn void Renderer.init(&self, Device device, Allocator allocator) {


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
