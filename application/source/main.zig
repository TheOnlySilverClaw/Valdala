const std = @import("std");
const transform = @import("transform.zig");
const glfw = @import("glfw");
const Controller = @import("input/controller.zig").Controller;
const Window = @import("input/window.zig").Window;
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

    var controller = Controller {
        .window = null
    };

    const window = Window.create("Valdala", 1000, 800, &controller);
    defer window.destroy();
    controller.window = &window;
    window.show();

    // const instance = webgpu.instance.create(undefined);
    // defer instance.release();

    // const surface = try glfw_webgpu.createSurface(window, instance);
    // defer surface.release();

    // const adapterResult = instance.requestAdapter(&webgpu.instance.RequestAdapterOptions {
    //     .compatible_surface = surface,
    //     .power_preference = .high_performance
    // });

    // const adapter = adapterResult.adapter orelse {
    //     return;
    // };
    // defer adapter.release();


    // var capabilities = webgpu.surface.SurfaceCapabilities.empty();
    // surface.getCapabilities(adapter, &capabilities);

    var file = try std.fs.cwd().openFile("textures/testing/texture_1.qoi", .{});
    var image = try qoi.decodeStream(allocator, file.reader());
    defer image.deinit(allocator);

    const text = try std.fs.cwd().readFileAlloc(allocator, "shaders/textured.wgsl", 16 * 1024);
    defer allocator.free(text);
    // log.debug("loaded shader:\n{s}\n", .{text});

    // log.info("texture image: {} * {} = {} px color spcace: {s}", .{ image.width, image.height, image.pixels.len, @tagName(image.colorspace) });
    
    log.info("Shutdown", .{});
}
