const std = @import("std");
const transform = @import("transform.zig");
const glfw = @import("glfw");
const webgpu = @import("webgpu");
const glfw_webgpu = @import("glfw-webgpu.zig");
const log = std.log;

pub fn main() !void {
    
    log.info("Launch", .{});

    try glfw.initialize();
    defer glfw.terminate();

    const window = glfw.window.create(1000, 800, "Valdala");
    defer window.destroy();

    const instance = webgpu.instance.create(undefined);
    defer instance.release();

    const surface = try glfw_webgpu.createSurface(window, instance);
    defer surface.release();

    const adapterResult = instance.requestAdapter(&webgpu.instance.RequestAdapterOptions {
        .compatible_surface = surface,
        .power_preference = .high_performance
    });

    const adapter = adapterResult.adapter orelse {
        return;
    };
    defer adapter.release();


    var capabilities = webgpu.surface.SurfaceCapabilities.empty();
    surface.getCapabilities(adapter, &capabilities);

    log.info("preferred surface texture format: {any}", .{capabilities.formats.?[0]});

    while (window.should_stay()) {
        glfw.pollEvents();
        std.Thread.sleep(10 * std.time.ns_per_s / 60);
    }

    log.info("Shutdown", .{});
}
