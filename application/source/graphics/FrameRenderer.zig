const std = @import("std");
const log = std.log;
const time = std.time;
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Surface = @import("Surface.zig");
const UserInterface = @import("UserInterface.zig");
const CubeRenderer = @import("CubeRenderer.zig");

const Self = @This();


allocator: Allocator,
clearColor: webgpu.Color = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 1 },
surface: *const Surface,
targetFrameTime: u64,
lastFrameEndTime: i64 = undefined,

userInterface: *UserInterface,
cubeRenderer: *CubeRenderer,

pub fn init(allocator: Allocator, targetFrameRate: u64, surface: *const Surface, userInterface: *UserInterface, cubeRenderer: *CubeRenderer) !Self {

    const targetFrameTime = time.ms_per_s / targetFrameRate;
    
    return .{
        .allocator = allocator,
        .surface = surface,
        .targetFrameTime = targetFrameTime,
        .lastFrameEndTime = time.milliTimestamp(),
        .userInterface = userInterface,
        .cubeRenderer = cubeRenderer
    };
}

pub fn deinit(self: Self) void {
    _ = self;
}

pub fn render(self: *Self) !void{

    const frameStartTime = time.milliTimestamp();
    const frameDeltaTime: u64 = @intCast(frameStartTime - self.lastFrameEndTime);

    if(frameDeltaTime == 0) return;

    const surface = self.surface;
    const device = surface.device;
    const queue = surface.getQueue();

    const commandEncoder = device.createCommandEncoder(null);
    
    const colorTexture = try surface.getColorTexture();
    const colorTextureView = colorTexture.createView(null);
    const depth_texture = surface.getDepthTexture().?;
    const depth_texture_view_descriptor = webgpu.TextureViewDescriptor {
        .label = webgpu.StringView.sized("depth"),
        .aspect = .depth_only,
        .dimension = .@"2d",
        .format = surface.depth_texture_format,
        .usage = .{ .render_attachment = true }
    };
    const depth_texture_view = depth_texture.createView(&depth_texture_view_descriptor);

    const colorAttachment = webgpu.RenderPassColorAttachment {
        .clear_value = self.clearColor,
        .load_op = .clear,
        .store_op = .store,
        .view = colorTextureView
    };

    const depth_stencil_attachment = webgpu.RenderPassDepthStencilAttachment {
        .depth_load_op = .clear,
        .depth_store_op = .store,
        .depth_clear_value = 1.0,
        .view = depth_texture_view,
        .stencil_read_only = 0
    };

    const renderPassDescriptor = webgpu.RenderPassDescriptor {
        .color_attachment_count = 1,
        .color_attachments = &.{ colorAttachment },
        .depth_stencil_attachment = &depth_stencil_attachment
    };

    const renderPass = commandEncoder.beginRenderPass(&renderPassDescriptor);
    
    try self.cubeRenderer.render(renderPass);
    try self.userInterface.render(renderPass, frameDeltaTime);

    renderPass.end();
    renderPass.release();

    const commandBuffer = commandEncoder.finish(null);
    commandEncoder.release();

    queue.submit(&.{ commandBuffer });
    commandBuffer.release();
    
    surface.present();

    colorTextureView.release();
    colorTexture.release();
    depth_texture_view.release();

    const currentFrameTime: u64 = @intCast(time.milliTimestamp() - frameStartTime);
    self.lastFrameEndTime = time.milliTimestamp();

    if(currentFrameTime < self.targetFrameTime) {
        const sleepTime = self.targetFrameTime - currentFrameTime;
        time.sleep(sleepTime * time.ns_per_ms);
    } else {
        log.warn("Frame rendering took {d} ms", .{ currentFrameTime });
    }

}