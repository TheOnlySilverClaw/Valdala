const std = @import("std");
const webgpu = @import("webgpu");
const fs = std.fs;
const Allocator = std.mem.Allocator;

pub const Shader = struct {
    
    entry: [*:0]const u8,
    module: *webgpu.ShaderModule,


    pub const source_size_limit = 64 * 1024;

    pub fn loadModule(allocator: Allocator, device: *webgpu.Device, path: []const u8, label: [*:0]const u8) !*webgpu.ShaderModule {

        const file = try fs.cwd().openFile(path, .{});
        defer file.close();

        const source = try file.readToEndAllocOptions(
            allocator, source_size_limit, source_size_limit / 4, @alignOf(u8), @as(u8, 0));
        defer allocator.free(source);

        const wgslDescriptor = webgpu.ShaderModuleWGSLDescriptor {
            .chain = .{ .type = .shader_module_wgsl_descriptor },
            .code = source
        };

        const descriptor = webgpu.ShaderModuleDescriptor {
            .next = &wgslDescriptor.chain,
            .label = label
        };

        return device.createShaderModule(&descriptor);
    }
};