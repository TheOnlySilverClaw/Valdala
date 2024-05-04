module webgpu

#flag -I include
#flag -L libraries

#flag -l c
#flag -l m
#flag -l unwind
#flag -l wgpu_native

#include "wgpu.h"


pub fn create_instance() !WGPUInstance {

	descriptor := C.WGPUInstanceDescriptor{}
	instance := C.wgpuCreateInstance(&descriptor)
	return instance
}

pub fn (instance WGPUInstance) release() {
	C.wgpuInstanceRelease(instance)
}

pub fn (instance WGPUInstance) request_adapter(surface WGPUSurface) !WGPUAdapter {

	options := C.WGPURequestAdapterOptions{
		powerPreference: .high_performance,
		compatibleSurface: surface
	}

	channel := chan WGPUAdapter{cap: 1}

	callback := fn [channel] (
		status WGPURequestAdapterStatus,
		adapter WGPUAdapter,
		message &char,
		user_data voidptr) {
		
		if status == .success {
			channel <- adapter
		} else {
			channel.close()
		}
	}

	C.wgpuInstanceRequestAdapter(instance, &options, callback, unsafe { nil })

	adapter := <- channel ?

	return adapter
}

pub fn (adapter WGPUAdapter) release() {
	C.wgpuAdapterRelease(adapter)
}

pub fn (adapter WGPUAdapter) request_device() !WGPUDevice {

	descriptor := C.WGPUDeviceDescriptor{
		label: "device".str,
		requiredFeatures: unsafe { nil },
		requiredLimits: unsafe { nil }
	}

	channel := chan WGPUDevice{cap: 1}

	callback := fn [channel] (
		status WGPURequestDeviceStatus,
		device WGPUDevice,
		message &char,
		user_data voidptr) {
		
		if status == .success {
			channel <- device
		} else {
			channel.close()
		}
	}

	C.wgpuAdapterRequestDevice(adapter, &descriptor, callback, unsafe { nil })

	device := <- channel ?

	error_callback := fn(errorType WGPUErrorType, message &char, user_data voidptr) {
		message_string := unsafe { message.vstring() }
		println("device error ($errorType): $message_string")
	}

	C.wgpuDeviceSetUncapturedErrorCallback(device, error_callback, unsafe { nil })

	return device
}

pub fn (device WGPUDevice) get_queue() WGPUQueue {
	return C.wgpuDeviceGetQueue(device)
}

pub fn (device WGPUDevice) create_command_encoder(label string) WGPUCommandEncoder {

	descriptor := C.WGPUCommandEncoderDescriptor {
		label: label.str
	}
	return C.wgpuDeviceCreateCommandEncoder(device, &descriptor)
}

pub fn (encoder WGPUCommandEncoder) begin_render_pass(view WGPUTextureView) WGPURenderPassEncoder {

	descriptor := C.WGPURenderPassDescriptor {
		label: unsafe { nil }
		colorAttachmentCount: 1,
		colorAttachments: &C.WGPURenderPassColorAttachment {
			view: view,
			resolveTarget: unsafe { nil }
			clearValue: C.WGPUColor {
				r: 0.9,
				g: 0.4,
				b: 0.0,
				a: 1.0
			},
			loadOp: .clear,
			storeOp: .store
		},
		depthStencilAttachment: unsafe { nil },
		timestampWrites: unsafe { nil }
	}

	return C.wgpuCommandEncoderBeginRenderPass(encoder, &descriptor)
}

pub fn (encoder WGPUCommandEncoder) finish() WGPUCommandBuffer {
	
	descriptor := C.WGPUCommandBufferDescriptor {
		label: unsafe { nil }
	}

	return C.wgpuCommandEncoderFinish(encoder, &descriptor)
}

pub fn (encoder WGPUCommandEncoder) release() {
	C.wgpuCommandEncoderRelease(encoder)
}

pub fn (encoder WGPURenderPassEncoder) end() {
	C.wgpuRenderPassEncoderEnd(encoder)
}

pub fn (encoder WGPURenderPassEncoder) release() {
	C.wgpuRenderPassEncoderRelease(encoder)
}

pub fn (buffer WGPUCommandBuffer) release() {
	C.wgpuCommandBufferRelease(buffer)
}

pub fn (surface WGPUSurface) get_current_texture() !WGPUTexture {

	surface_texture := C.WGPUSurfaceTexture {}

	C.wgpuSurfaceGetCurrentTexture(surface, &surface_texture)

	if surface_texture.status == .success {
		return surface_texture.texture
	} else {
		return error("surface texture error: ${surface_texture.status}")
	}
}

pub fn (texture WGPUTexture) get_view(mip_levels u32) WGPUTextureView {
	
	descriptor := C.WGPUTextureViewDescriptor {
		label: unsafe { nil },
		mipLevelCount: mip_levels,
		arrayLayerCount: 1
	}
	return C.wgpuTextureCreateView(texture, &descriptor)
}

pub fn (queue WGPUQueue) submit(command WGPUCommandBuffer) {
	C.wgpuQueueSubmit(queue, 1, &command)
}

pub fn (queue WGPUQueue) release() {
	C.wgpuQueueRelease(queue)
}

pub fn (device WGPUDevice) release() {
	C.wgpuDeviceRelease(device)
}

pub fn (surface WGPUSurface) configure(adapter WGPUAdapter, device WGPUDevice) {
	
	capabilities := C.WGPUSurfaceCapabilities {
		formats: unsafe { nil },
		presentModes: unsafe { nil },
		alphaModes: unsafe { nil }
	}
	
	C.wgpuSurfaceGetCapabilities(surface, adapter, &capabilities)

	configuration := C.WGPUSurfaceConfiguration {
		device: device,
		usage: .render_attachment,
		format: unsafe { capabilities.formats[0] },
		presentMode: .fifo,
		alphaMode: unsafe { capabilities.alphaModes[0] },
		viewFormats: capabilities.formats,
		viewFormatCount: capabilities.formatCount,
		// TODO resize with window
		width: 1200,
		height: 1000
	}

	C.wgpuSurfaceConfigure(surface, &configuration)
}

pub fn (surface WGPUSurface) present() {
	C.wgpuSurfacePresent(surface)
}

pub fn (surface WGPUSurface) release() {
	C.wgpuSurfaceRelease(surface)
}

pub fn (texture WGPUTexture) release() {
	C.wgpuTextureRelease(texture)
}

pub fn (view WGPUTextureView) release() {
	C.wgpuTextureViewRelease(view)
}