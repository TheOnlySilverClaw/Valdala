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
    
    glfw.window.hint(glfw.window.HintKey.ClientApi, glfw.window.no_api);

    var controller = Controller {
        .window = null
    };
    
    var window: Window = undefined;
    try Window.create(&window, "Valdala", 1000, 800, &controller);
    defer window.destroy();
    controller.window = &window;

    window.show();

    var file = try std.fs.cwd().openFile("textures/testing/texture_1.qoi", .{});
    var image = try qoi.decodeStream(allocator, file.reader());
    defer image.deinit(allocator);

    const text = try std.fs.cwd().readFileAlloc(allocator, "shaders/textured.wgsl", 16 * 1024);
    defer allocator.free(text);
    
    log.info("Shutdown", .{});
}
