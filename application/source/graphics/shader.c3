module graphics;

import std::io::file;
import webgpu;

fault ShaderError {
    COMPILATION_FAILED
}

fn ShaderModule! loadShaderModule(String path, Device device, Allocator allocator) {

    File file = file::open(path, "r")!;

    DString content;
    defer content.free();
    content.new_init(1024 * 4, allocator);
    content.read_from_stream(&file)!;

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
