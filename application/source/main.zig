const std = @import("std");
const transform = @import("transform.zig");
const glfw = @import("glfw.zig");
const log = std.log;

pub fn main() !void {
    
    log.info("Launch", .{});

    try glfw.init();
    defer glfw.terminate();

    const window = glfw.Window.create(1000, 800, "Valdala");
    defer window.destroy();

    while (window.should_stay()) {
        glfw.pollEvents();
        std.Thread.sleep(10 * std.time.ns_per_s / 60);
    }

    log.info("Shutdown", .{});
}
