const std = @import("std");
const transform = @import("transform.zig");
const glfw = @import("glfw");
const webgpu = @import("webgpu");
const Window = glfw.window.Window;
const log = std.log;

pub fn main() !void {
    
    log.info("Launch", .{});

    try glfw.initialize();
    defer glfw.terminate();

    const window = Window.create(1000, 800, "Valdala");
    defer window.destroy();

    const instance = webgpu.instance.createInstance(null);
    defer instance.release();

    while (window.should_stay()) {
        glfw.pollEvents();
        std.Thread.sleep(10 * std.time.ns_per_s / 60);
    }

    log.info("Shutdown", .{});
}
