const std = @import("std");
const transform = @import("transform.zig");
const glfw = @import("glfw");
const webgpu = @import("webgpu");
const glfw_webgpu = @import("glfw-webgpu.zig");
const log = std.log;
const qoi = @import("qoi");

pub fn main() !void {
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check = gpa.deinit();
        if(check == .leak) {
            log.warn("memory leaks detected!", .{});
        }
    }

    const allocator = gpa.allocator();

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

    var file = try std.fs.cwd().openFile("textures/testing/texture_1.qoi", .{});
    var image = try qoi.decodeStream(allocator, file.reader());
    defer image.deinit(allocator);

    log.info("texture image: {} * {} = {} px color spcace: {s}", .{ image.width, image.height, image.pixels.len, @tagName(image.colorspace) });

    log.info("preferred surface texture format: {any}", .{capabilities.formats.?[0]});

    while (window.should_stay()) {
        glfw.pollEvents();
        std.Thread.sleep(10 * std.time.ns_per_s / 60);
    }

    log.info("Shutdown", .{});
}
