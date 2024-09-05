module webgpu;
import std::io;

fn Adapter! Instance.requestAdapter(Instance instance, RequestAdapterOptions* options) {

    Adapter adapter = null;

    RequestAdapterCallback callback = fn void(RequestAdapterStatus status,
        Adapter adapter, ZString message, UserData result) {

        if(status == SUCCESS) {
            *(Adapter*) result = adapter;
        }
    };

    instance.requestAdapterAsync(options, callback, &adapter);

    if(adapter == null) {
        return AdapterError.REQUEST_FAILED?;
    } else {
        return adapter;
    }
}
