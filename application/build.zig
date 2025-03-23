const std = @import("std");

const Target = std.Target;

const panic = std.debug.panic;


pub fn build(b: *std.Build) void {

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const glfw = b.dependency("glfw", .{}).module("glfw");

    const webgpu = b.dependency("webgpu", .{}).module("webgpu");

    const algebra = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/algebra/module.zig")
    });

    const common = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/common//module.zig")
    });

    const graphics = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/graphics/module.zig")
    });

    const ui = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/ui//module.zig")
    });

    const worldgen = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/worldgen/module.zig")
    });

    const zigimg = b.dependency("zigimg", .{}).module("zigimg");
    const TrueType = b.dependency("TrueType", .{}).module("TrueType");

    const exe = b.addExecutable(.{
        .name = "Valdala",
        .root_source_file = b.path("source/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();
    exe.linkSystemLibrary("unwind");

    switch (target.result.os.tag) {
        .linux => {
            exe.addObjectFile(.{ .cwd_relative = "libraries/glfw/linux/libglfw3.a" });
            exe.addObjectFile(b.lazyDependency("wgpu_linux", .{}).?.path("lib/libwgpu_native.a"));
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

            // objective-c helper function to get metal layer
            const metal_layer_mod = b.addModule("metalLayer", .{
                .optimize = optimize,
                .target = target,
            });
            metal_layer_mod.addCSourceFile(.{ .file = b.path("source/glfw/metal_layer.m") });

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
                else => @panic("Unsupported architechture for macOS")

            }
        },
        else => std.debug.panic("Unsupported operating system: {s}", .{ @tagName(target.result.os.tag) })
    }


    graphics.addImport("common", common);
    graphics.addImport("glfw", glfw);
    graphics.addImport("webgpu", webgpu);
    graphics.addImport("algebra", algebra);
    graphics.addImport("TrueType", TrueType);
    graphics.addImport("zigimg", zigimg);

    ui.addImport("glfw", glfw);
    ui.addImport("webgpu", webgpu);
    ui.addImport("graphics", graphics);

    worldgen.addImport("common", common);

    exe.root_module.addImport("common", common);
    exe.root_module.addImport("zigimg", zigimg);
    exe.root_module.addImport("glfw", glfw);
    exe.root_module.addImport("webgpu", webgpu);
    exe.root_module.addImport("graphics", graphics);
    exe.root_module.addImport("ui", ui);
    exe.root_module.addImport("worldgen", worldgen);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("source/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
