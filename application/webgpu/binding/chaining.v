module binding

pub struct C.WGPUChainedStruct {
pub:
	next  &C.WGPUChainedStruct
	sType WGPUSType
}

pub struct C.WGPUChainedStructOut {
pub:
	next  &C.WGPUChainedStructOut
	sType WGPUSType
}

pub enum WGPUSType {
	invalid                                       = 0x00000000
	surface_descriptor_from_metal_layer           = 0x00000001
	surface_descriptor_from_windows_hwnd          = 0x00000002
	surface_descriptor_from_xlib_window           = 0x00000003
	surface_descriptor_from_canvas_html_selector  = 0x00000004
	shader_module_spirv_descriptor                = 0x00000005
	shader_module_wgsl_descriptor                 = 0x00000006
	primitive_depth_clip_control                  = 0x00000007
	surface_descriptor_from_wayland_surface       = 0x00000008
	surface_descriptor_from_android_native_window = 0x00000009
	surface_descriptor_from_xcb_window            = 0x0000000A
	render_pass_descriptor_max_draw_count         = 0x0000000F
}
