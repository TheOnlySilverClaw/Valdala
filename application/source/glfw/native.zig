const window = @import("window.zig");


pub const X11Display = *anyopaque;

pub const X11Window = u64;


pub const getX11Display = glfwGetX11Display;

pub const getX11Window = glfwGetX11Window;


extern fn glfwGetX11Display() X11Display;

extern fn glfwGetX11Window(window: window.Window) X11Window;



pub const WaylandDisplay = *anyopaque;

pub const WaylandWindow = *anyopaque;


pub const getWaylandDisplay = glfwGetWaylandDisplay;

pub const getWaylandWindow = glfwGetWaylandWindow;


extern fn glfwGetWaylandDisplay() WaylandDisplay;

extern fn glfwGetWaylandWindow(window: window.Window) WaylandWindow;