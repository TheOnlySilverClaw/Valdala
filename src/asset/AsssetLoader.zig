const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const zigimg = @import("zigimg");
const webgpu = @import("webgpu");
const yaml = @import("yaml");

const Allocator = mem.Allocator;

const Self = @This();

allocator: Allocator,
device: *webgpu.Device,
root: []const u8,

pub fn init(allocator: Allocator, device: *webgpu.Device, root: []const u8) !Self {

    return .{
        .allocator = allocator,
        .device = device,
        .root= root,
    };
}

pub fn deinit(self: Self) void {
    _ = self;
}


const shader_max_bytes = 1024 * 64;

pub fn loadShader(self: Self, path: []const u8) !*webgpu.ShaderModule {

    const full_path = try fs.path.join(self.allocator, &.{ self.root, "shader", path });
    defer self.allocator.free(full_path);

    const file = try fs.cwd().openFile(full_path, .{});
    defer file.close();

    const source = try file.readToEndAlloc(self.allocator, shader_max_bytes);
    defer self.allocator.free(source);

    const source_descriptor = webgpu.ShaderSourceWGSL {
        .chain = .{ .type = .shader_source_wgsl },
        .code = webgpu.StringView.sized(source)
    };

    const file_name = fs.path.basename(path);
    var split = mem.splitScalar(u8, file_name, '.');
    const shader_name = split.next();

    const descriptor = webgpu.ShaderModuleDescriptor {
        .next = &source_descriptor.chain,
        .label = if(shader_name) |name| webgpu.StringView.sized(name) else .empty
    };

    return self.device.createShaderModule(&descriptor);
}
