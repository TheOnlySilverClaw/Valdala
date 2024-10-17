const shared = @import("shared.zig");


pub const ShaderModule = *opaque {
    
    pub fn getCompilationInfo(module: ShaderModule,
        callback: CompilationInfoCallback, userdata: ?*anyopaque) void {
        wgpuShaderModuleGetCompilationInfo(module, callback, userdata);
    }

    pub fn setLabel(module: ShaderModule, label: ?[*:0]const u8) void {
        wgpuShaderModuleSetLabel(module, label);
    }

    pub fn reference(module: ShaderModule) void {
        wgpuShaderModuleReference(module);
    }

    pub fn release(module: ShaderModule) void {
        wgpuShaderModuleRelease(module);
    }
};

pub const CompilationInfo = extern struct {
    next: ?*const shared.ChainedStruct = null,
    message_count: usize,
    messages: ?[*]const CompilationMessage
};

pub const CompilationInfoCallback = *const fn (
    status: CompilationInfoRequestStatus,
    info: *const CompilationInfo,
    userdata: ?*anyopaque
) callconv(.C) void;

pub const CompilationInfoRequestStatus = enum(u32) {
    success,
    failure,
    device_lost,
    unknown
};

pub const CompilationMessage = extern struct {
    next: ?*const shared.ChainedStruct = null,
    message: ?[*:0]const u8 = null,
    message_type: CompilationMessageType,
    line_num: u64,
    line_pos: u64,
    offset: u64,
    length: u64,
    utf16_line_pos: u64,
    utf16_offset: u64,
    utf16_length: u64
};

pub const CompilationMessageType = enum(u32) {
    failure,
    warning,
    info
};

pub const ShaderModuleDescriptor = extern struct {
    next: ?*const shared.ChainedStruct = null,
    label: ?[*:0]const u8 = null
};

pub const ShaderModuleWGSLDescriptor = extern struct {
    chain: shared.ChainedStruct,
    code: [*:0]const u8
};


extern fn wgpuShaderModuleGetCompilationInfo(module: ShaderModule,
    callback: CompilationInfoCallback, userdata: ?*anyopaque) void;

extern fn wgpuShaderModuleSetLabel(module: ShaderModule, label: ?[*:0]const u8) void;

extern fn wgpuShaderModuleReference(module: ShaderModule) void;

extern fn wgpuShaderModuleRelease(module: ShaderModule) void;
