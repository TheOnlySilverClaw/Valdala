module binding

pub type WGPURequestAdapterCallback = fn (status WGPURequestAdapterStatus, adapter WGPUAdapter, message &char, user_data voidptr)

pub type WGPURequestDeviceCallback = fn (status WGPURequestDeviceStatus, device WGPUDevice, message &char, user_data voidptr)

pub type WGPUDeviceLostCallback = fn (reason WGPUDeviceLostReason, message &char, user_data voidptr)

pub type WGPUErrorCallback = fn (errorType WGPUErrorType, message &char, user_data voidptr)
