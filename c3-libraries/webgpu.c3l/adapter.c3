module webgpu;

fn Device! Adapter.requestDevice(Adapter adapter, DeviceDescriptor* descriptor = null) {

    Device device = null;

    RequestDeviceCallback callback = fn void (RequestDeviceStatus status,
	    Device device, ZString message, UserData result) {

        if(status == SUCCESS) {
            *(Device*) result = device;
        }
    };

    adapter.requestDeviceAsync(descriptor, callback, &device);

    if(device == null) {
        return DeviceError.REQUEST_FAILED?;
    } else {
        return device;
    }
}