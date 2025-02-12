const std = @import("std");
const webgpu = @import("webgpu");

const Allocator = std.mem.Allocator;
const Pipeline = @import("TextRenderPipeline.zig");
const Color = @import("Color.zig").Color(u8);
const Surface = @import("Surface.zig");
const Shader = @import("shader.zig").Shader;
const Self = @This();

pipeline: Pipeline,

pub fn init(allocator: Allocator, surface: Surface) !Self {

    const device = surface.device;

    const shader = try Shader.loadModule(allocator, device, "shaders/text.wgsl", "text");

    const pipeline = Pipeline.create(device, surface.colorTextureFormat, shader);

    return .{
        .pipeline = pipeline
    };
}