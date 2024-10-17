pub const Undefined = ~0;

pub const CompareFunction = enum(u32) {
    undefined,
    never,
    less,
    less_equal,
    greater,
    greater_equal,
    equal,
    not_equal,
    always
};

pub const ConstantEntry = extern struct {
    next: ?*const ChainedStruct = null,
    key: [*:0]const u8,
    value: f64,
};

pub const ChainedStruct = extern struct {
    next: ?*const ChainedStruct,
    type: StructType,
};

pub const ChainedStructOut = extern struct {
    next: ?*ChainedStructOut,
    type: StructType
};

pub const Color = extern struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};

pub const ErrorCallback = *const fn (
    type: ErrorType,
    message: ?[*:0]const u8,
    userdata: ?*anyopaque,
) callconv(.C) void;

pub const ErrorType = enum(u32) {
    none,
    validation,
    memory,
    internal,
    unknown,
    device_lost
};

pub const Extent3D = extern struct {
    width: u32,
    height: u32,
    depth: u32 = 1
};

pub const Origin3D = extern struct {
    x: u32 = 0,
    y: u32 = 0,
    z: u32 = 0
};

pub const StructType = enum(u32) {
    invalid,
    surface_descriptor_from_metal_layer,
    surface_descriptor_from_windows_hwnd,
    surface_descriptor_from_xlib_window,
    surface_descriptor_from_canvas_html_selector,
    shader_module_spirv_descriptor,
    shader_module_wgsl_descriptor,
    surface_descriptor_from_wayland_surface,
    surface_descriptor_from_android_native_window,
    surface_descriptor_from_xcb_window,
    render_pass_descriptor_max_draw_count
};
