module webgpu;
import std::io;

fault InstanceError {
    ADAPTER_REQUEST_FAILED
}

fn Adapter! Instance.awaitAdapter(Instance instance, Surface surface, bool highPerformance = true) {

    Adapter adapter = null;

    RequestAdapterOptions options;
    options.compatibleSurface = surface;
    if(highPerformance) {
        options.powerPreference = HIGH_PERFORMANCE;
    }

    RequestAdapterCallback callback = fn void(RequestAdapterStatus status,
        Adapter adapter, ZString message, UserData result) {

        if(status == SUCCESS) {
            *(Adapter*) result = adapter;
        }
    };

    instance.requestAdapter(&options, callback, &adapter);

    if(adapter == null) {
        return InstanceError.ADAPTER_REQUEST_FAILED?;
    } else {
        return adapter;
    }
}
