const std = @import("std");
const glfw = @import("glfw");
const Controller = @import("input/controller.zig").Controller;
const Renderer = @import("graphics/renderer.zig").Renderer;
const Camera = @import("graphics/camera.zig").Camera;
const Window = @import("input/window.zig").Window;
const webgpu = @import("webgpu");
const glfw_webgpu = @import("glfw-webgpu.zig");
const log = std.log;
const zigimg = @import("zigimg");


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

    var window: Window = undefined;
    try window.create("Valdala", 1000, 800);
    defer window.destroy();
    
    const controller = Controller {
        .window = &window
    };

    // TODO figure out where ot put this
    const pipeline = try @import("graphics/render_pipeline.zig").RenderPipeline
        .create(allocator, window.surface);

    var camera = Camera.new(2.0,1000, 800, 100.0);
    camera.transform.translateZ(-3);
    camera.transform.rotatePitch(std.math.degreesToRadians(90));

    const renderer = Renderer {
        .surface = &window.surface,
        .camera = &camera,
        .pipeline = &pipeline,
        .allocator = allocator
    };

    window.controller = &controller;
    window.renderer = &renderer;

    try window.show();

    var file = try std.fs.cwd().openFile("textures/testing/texture_1.qoi", .{});
    var image = try zigimg.ImageUnmanaged.fromFile(allocator, &file);
    defer image.deinit(allocator);

    const text = try std.fs.cwd().readFileAlloc(allocator, "shaders/textured.wgsl", 16 * 1024);
    defer allocator.free(text);
    
    log.info("Shutdown", .{});
}
