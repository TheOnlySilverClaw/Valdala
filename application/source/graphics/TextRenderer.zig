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
fontTexture: *FontTexture,
surface: *const Surface,
samplerBindGroup: *webgpu.BindGroup,
variableBindGroup: *webgpu.BindGroup,


pub fn init(allocator: Allocator, surface: *const Surface, fontTexture: *FontTexture) !Self {

    const device = surface.device;

    const shader = try Shader.loadModule(allocator, device, "shaders/text.wgsl", "text");

    const pipeline = Pipeline.create(device, surface.colorTextureFormat, shader);

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
        .texture_view = fontTexture.createView()
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
        .fontTexture = fontTexture,
        .surface = surface,
        .samplerBindGroup = samplerBindGroup,
        .variableBindGroup = variableBindGroup
    };
}


pub fn bind(self: *Self, renderPass: *webgpu.RenderPassEncoder) !void {

    renderPass.setPipeline(self.pipeline.handle);
    renderPass.setBindGroup(0, self.samplerBindGroup, null);
    renderPass.setBindGroup(1, self.variableBindGroup, null);
}

pub fn deinit(self: *Self) void {

    self.fontTexture.deinit();
    self.allocator.destroy(self.fontTexture);
}
