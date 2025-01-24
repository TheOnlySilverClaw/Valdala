const std = @import("std");

pub fn build(b: *std.Build) void {
                    
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const glfw = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/glfw/module.zig")
    });

    const webgpu = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/webgpu/module.zig")
    });

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

    const input = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/input//module.zig")
    });

    const worldgen = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/worldgen/module.zig")
    });

    const application = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("source/application//module.zig")
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
    exe.addObjectFile(.{ .cwd_relative = "libraries/libglfw3.a" });
    exe.addObjectFile(.{ .cwd_relative = "libraries/libwgpu_native.a" });

    graphics.addImport("common", common);
    graphics.addImport("glfw", glfw);
    graphics.addImport("webgpu", webgpu);
    graphics.addImport("algebra", algebra);
    graphics.addImport("TrueType", TrueType);
    graphics.addImport("zigimg", zigimg);

    input.addImport("glfw", glfw);
    input.addImport("webgpu", webgpu);
    input.addImport("graphics", graphics);

    worldgen.addImport("common", common);
    // temporarily, for output verification
    worldgen.addImport("zigimg", zigimg);

    application.addImport("common", common);
    application.addImport("zigimg", zigimg);
    application.addImport("glfw", glfw);
    application.addImport("webgpu", webgpu);
    application.addImport("graphics", graphics);
    application.addImport("input", input);
    application.addImport("worldgen", worldgen);

    exe.root_module.addImport("application", application);

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
