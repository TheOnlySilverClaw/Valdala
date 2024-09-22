module graphics;

import std::io;
import webgpu;
import asset;

fault ShaderError {
    COMPILATION_FAILED
}

fn ShaderModule! loadShaderModule(String path, Device device, Allocator allocator) {

    DString content = asset::loadText(path, allocator)!;
    defer content.free();

    ShaderModuleWGSLDescriptor wgslDescriptor;
    wgslDescriptor.chain.sType = SHADER_MODULE_WGSL_DESCRIPTOR;
    wgslDescriptor.code = content.zstr_view();

    ShaderModuleDescriptor descriptor;
    descriptor.next = &wgslDescriptor.chain;

    CompilationInfoRequestStatus status = UNKNOWN;

    ShaderModule shaderModule = device.createShaderModule(&descriptor);
    /* currently not available
    shaderModule.getCompilationInfo(fn void(
        CompilationInfoRequestStatus status, CompilationInfo* info, UserData data) {

        *(CompilationInfoRequestStatus*) data = status;

        for(int i = 0; i < info.messageCount; i++) {
            io::printfn("[%d]\t%s", i, info.messages[i]);
        }

    }, &status);

    io::printfn("shader compilation status: %s", status);
    */

    return shaderModule;
    /*
    if(status == SUCCESS) {
        return shaderModule;
    } else {
        return ShaderError.COMPILATION_FAILED?;
    }
    */

}
