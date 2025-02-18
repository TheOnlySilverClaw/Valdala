const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Pipeline = @import("TextRenderPipeline.zig");
const Color = @import("color.zig").Color(f32);
const Surface = @import("Surface.zig");
const Shader = @import("shader.zig").Shader;
const FontTexture = @import("FontTexture.zig");
const Sampler = @import("Sampler.zig");
const TextMesh = @import("TextMesh.zig");
const ArrayList = std.ArrayListUnmanaged;


const Self = @This();

allocator: Allocator,
pipeline: Pipeline,
fontTexture: FontTexture,
surface: Surface,
samplerBindGroup: webgpu.BindGroup,
variableBindGroup: webgpu.BindGroup,


pub fn init(allocator: Allocator, surface: Surface) !Self {

    const device = surface.device;

    const shader = try Shader.loadModule(allocator, device, "shaders/text.wgsl", "text");

    const pipeline = Pipeline.create(device, surface.colorTextureFormat, shader);

    const fontSize = 24;

    const fontBytes = try std.fs.cwd().readFileAlloc(allocator, "fonts/FiraCode/FiraCode-Regular.ttf", 1_000_000);
    var fontTexure = try FontTexture.init(allocator, device, fontBytes, fontSize, 127);
    try fontTexure.loadASCII();

    const sampler = Sampler.createLinearClamped(device);
    const samplerEntry = webgpu.BindGroupEntry {
        .binding = 0,
        .sampler = sampler
    };
    const samplerGroupDescriptor = webgpu.BindGroupDescriptor {
        .entries = &.{ samplerEntry },
        .entry_count = 1,
        .layout = pipeline.handle.getBindGroupLayout(0)
    };
    const samplerBindGroup = device.createBindGroup(&samplerGroupDescriptor);

    const textureEntry = webgpu.BindGroupEntry {
        .binding = 0,
        .texture_view = fontTexure.createView()
    };

    const screenSizeBuffer = device.createBuffer(&webgpu.BufferDescriptor {
        .label = "screen size",
        .size = @sizeOf([2]f32),
        .usage = .{ .uniform = true, .copy_dst = true }
    });

    const screenSize = [2]f32 {
        @floatFromInt(surface.width),
        @floatFromInt(surface.height)
    };

    surface.getQueue().writeBuffer(screenSizeBuffer, f32, &screenSize, 0);

    const screenSizeEntry = webgpu.BindGroupEntry {
        .binding = 1,
        .buffer = screenSizeBuffer,
        .size = screenSizeBuffer.size(),
        .offset = 0
    };

    const textColorBuffer = device.createBuffer(&webgpu.BufferDescriptor {
        .label = "text color",
        .size = @sizeOf(Color) * 1,
        .usage = .{ .uniform = true, .copy_dst = true }
    });

    const color = Color.rgb(1, 16.0 / 255.0, 240.0 / 255.0);
    surface.queue.writeBuffer(textColorBuffer, Color, &.{ color }, 0);

    const textColorEntry = webgpu.BindGroupEntry {
        .binding = 2,
        .buffer = textColorBuffer,
        .size = textColorBuffer.size(),
        .offset = 0
    };

    const variableEntries = [_] webgpu.BindGroupEntry {
        textureEntry,
        screenSizeEntry,
        textColorEntry
    };

    const variableGroupDescriptor = webgpu.BindGroupDescriptor {
        .entries = variableEntries[0..],
        .entry_count = variableEntries.len,
        .layout = pipeline.handle.getBindGroupLayout(1)
    };
    const variableBindGroup = device.createBindGroup(&variableGroupDescriptor);
    
    return .{
        .allocator = allocator,
        .pipeline = pipeline,
        .fontTexture = fontTexure,
        .surface = surface,
        .samplerBindGroup = samplerBindGroup,
        .variableBindGroup = variableBindGroup
    };
}


pub fn render(self: *Self, delta: u64) !void {

    const surface = self.surface;
    const device = surface.device;
    const queue = surface.getQueue();

    const fps: f32 = @as(f32, @floatFromInt(std.time.ms_per_s)) / @as(f32, @floatFromInt(delta));
    var buffer: [20]u8 = undefined;
    const slice = try std.fmt.bufPrint(&buffer, "{d:5} ms {d:3.0} fps", .{ delta, fps });

    var performanceMesh = try TextMesh.init(self.allocator, device, queue, 
        &self.fontTexture, .{ .x = 10, .y = 10 }, slice);
    defer performanceMesh.destroy();

    const commandEncoder = device.createCommandEncoder(null);
    
    const frameTexture = try surface.getColorTexture();
    const frameTextureView = frameTexture.createView(null);

    const colorAttachment = webgpu.RenderPassColorAttachment {
        .clear_value = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 1 },
        .load_op = .clear,
        .store_op = .store,
        .view = frameTextureView
    };

    const renderPassDescriptor = webgpu.RenderPassDescriptor {
        .color_attachment_count = 1,
        .color_attachments = &.{ colorAttachment }
    };

    const renderPass = commandEncoder.beginRenderPass(&renderPassDescriptor);

    renderPass.setPipeline(self.pipeline.handle);
    renderPass.setBindGroup(0, self.samplerBindGroup, null);
    renderPass.setBindGroup(1, self.variableBindGroup, null);
    
    performanceMesh.render(renderPass);

    renderPass.end();
    renderPass.release();

    const commandBuffer = commandEncoder.finish(null);
    commandEncoder.release();

    queue.submit(&.{ commandBuffer });
    commandBuffer.release();
    
    surface.present();

    frameTextureView.release();
    frameTexture.release();
}

pub fn deinit(self: *Self) void {

    self.fontTexture.deinit();
}
