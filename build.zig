const std = @import("std");
const Build = std.Build;
const Target = std.Target;

const panic = std.debug.panic;


pub fn build(b: *Build) void {

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Valdala",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    linkLibraries(b, exe, target, optimize);
    organizeModules(b, exe.root_module, target, optimize);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}


fn organizeModules(b: *std.Build, root: *Build.Module, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {

    const zigimg = b.dependency("zigimg", .{}).module("zigimg");
    const TrueType = b.dependency("TrueType", .{}).module("TrueType");
    
    const glfw = b.dependency("glfw", .{}).module("glfw");
    const webgpu = b.dependency("webgpu", .{}).module("webgpu");

    const client = b.addModule("client", .{
        .root_source_file = b.path("src/client/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const server = b.addModule("server", .{
        .root_source_file = b.path("src/server/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    client.addImport("zigimig", zigimg);
    client.addImport("TrueType", TrueType);
    client.addImport("glfw", glfw);
    client.addImport("webgpu", webgpu);

    root.addImport("client", client);
    root.addImport("server", server);
}

fn linkLibraries(b: *Build, exe: *Build.Step.Compile, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {

    exe.linkLibC();
    exe.linkSystemLibrary("unwind");

    switch (target.result.os.tag) {
        .linux => {
            exe.addObjectFile(b.path("lib/linux/libglfw3.a"));
            if(b.lazyDependency("wgpu_linux", .{})) |wgpu_dep| exe.addObjectFile(wgpu_dep.path("lib/libwgpu_native.a"));
        },
        .windows => {
            if (b.lazyDependency("glfw_windows", .{})) |glfw_dep| exe.addObjectFile(glfw_dep.path("lib-mingw-w64/libglfw3.a"));
            if (b.lazyDependency("wgpu_windows", .{})) |wgpu_dep| exe.addObjectFile(wgpu_dep.path("lib/libwgpu_native.a"));

            exe.linkLibCpp();

            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("user32");
            exe.linkSystemLibrary("shell32");

            // Required by wgpu_native
            exe.linkSystemLibrary("ole32");
            exe.linkSystemLibrary("user32");
            exe.linkSystemLibrary("kernel32");
            exe.linkSystemLibrary("userenv");
            exe.linkSystemLibrary("ws2_32");
            exe.linkSystemLibrary("oleaut32");
            exe.linkSystemLibrary("opengl32");
            exe.linkSystemLibrary("d3dcompiler_47");
            exe.linkSystemLibrary("propsys");
            exe.linkSystemLibrary("api-ms-win-core-winrt-error-l1-1-0");
        },
        .macos => {
            // needed for wgpu and glfw, does require a mac with xcode setup
            exe.linkFramework("Metal");
            exe.linkFramework("Cocoa");
            exe.linkFramework("Foundation");
            exe.linkFramework("QuartzCore");
            exe.linkFramework("IOKit");

            const metal_layer_mod = b.addModule("metalLayer", .{
                .optimize = optimize,
                .target = target,
            });
            exe.addCSourceFile(.{ .file = b.path("src/glfw/metal_layer.m") });

            exe.linkLibrary(b.addLibrary(.{
                .name = "metalLayer",
                .root_module = metal_layer_mod,
            }));

            switch (target.result.cpu.arch) {
                .aarch64 => { // apple silicon
                    if (b.lazyDependency("glfw_macos", .{})) |glfw_dep| {
                        exe.addObjectFile(glfw_dep.path("lib-arm64/libglfw3.a"));
                    }
                    if (b.lazyDependency("wgpu_macos_aarch64", .{})) |wgpu_dep| {
                        exe.addObjectFile(wgpu_dep.path("lib/libwgpu_native.a"));
                    }
                },
                .x86_64 => { // intel
                    if (b.lazyDependency("glfw_macos", .{})) |glfw_dep| {
                        exe.addObjectFile(glfw_dep.path("lib-x86_64/libglfw3.a"));
                    }
                    if (b.lazyDependency("wgpu_macos_x86_64", .{})) |wgpu_dep| {
                        exe.addObjectFile(wgpu_dep.path("lib/libwgpu_native.a"));
                    }
                },
                else => panic("Unsupported architechture for macOS: {s}", .{ @tagName(target.result.cpu.arch )})

            }
        },
        else => panic("Unsupported operating system: {s}", .{ @tagName(target.result.os.tag) })
    }
}