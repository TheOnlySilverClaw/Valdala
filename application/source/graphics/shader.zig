const std = @import("std");
const webgpu = @import("webgpu");
const fs = std.fs;
const Allocator = std.mem.Allocator;

pub const Shader = struct {
    
    entry: webgpu.StringView,
    module: *webgpu.ShaderModule,


    pub const source_size_limit = 64 * 1024;

    pub fn loadModule(allocator: Allocator, device: *webgpu.Device, path: []const u8, label: []const u8) !*webgpu.ShaderModule {

        const file = try fs.cwd().openFile(path, .{});
        defer file.close();

        const source = try file.readToEndAllocOptions(
            allocator, source_size_limit, source_size_limit / 4, @alignOf(u8), @as(u8, 0));
        defer allocator.free(source);

        const wgslDescriptor = webgpu.ShaderSourceWGSL {
            .chain = .{ .type = .shader_source_wgsl },
            .code = webgpu.StringView.sized(source)
        };

        const descriptor = webgpu.ShaderModuleDescriptor {
            .next = &wgslDescriptor.chain,
            .label = webgpu.StringView.sized(label)
        };

        return device.createShaderModule(&descriptor);
    }
};