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


    linkLibraries(b, exe, target, optimize);
    organizeModules(b, exe.root_module, exe_unit_tests.root_module, target, optimize);
}


fn organizeModules(b: *std.Build, root: *Build.Module, test_root: *Build.Module, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {

    const zigimg = b.dependency("zigimg", .{}).module("zigimg");
    const TrueType = b.dependency("TrueType", .{}).module("TrueType");
    const yaml = b.dependency("yaml", .{}).module("yaml");
    const glfw = b.dependency("glfw", .{}).module("glfw");
    const webgpu = b.dependency("webgpu", .{}).module("webgpu");
    _ = TrueType;

    // TODO move to separate repository?
    const glfw_webgpu = b.addModule("glfw-webgpu", .{
        .root_source_file = b.path("src/glfw-wgpu/surface.zig" ),
        .target = target,
        .optimize = optimize
    });
    if(target.result.os.tag == .macos) {
        glfw_webgpu.addCSourceFile(.{ .file = b.path("src/glfw-wgpu/metal_layer.m") });
    }
    
    const algebra = b.addModule("algebra", .{
        .root_source_file = b.path("src/algebra/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const coordinate = b.addModule("coordinate", .{
        .root_source_file = b.path("src/coordinate/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const color = b.addModule("color", .{
        .root_source_file = b.path("src/color.zig" ),
        .target = target,
        .optimize = optimize
    });

    const world = b.addModule("world", .{
        .root_source_file = b.path("src/world/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const module = b.addModule("module", .{
        .root_source_file = b.path("src/module/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const gui = b.addModule("gui", .{
        .root_source_file = b.path("src/gui/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const graphics = b.addModule("graphics", .{
        .root_source_file = b.path("src/graphics/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const scene = b.addModule("scene", .{
        .root_source_file = b.path("src/scene/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const simulation = b.addModule("simulation", .{
        .root_source_file = b.path("src/simulation/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const protocol = b.addModule("protocol", .{
        .root_source_file = b.path("src/protocol/module.zig" ),
        .target = target,
        .optimize = optimize
    });

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

    coordinate.addImport("algebra", algebra);

    world.addImport("algebra", algebra);
    world.addImport("coordinate", coordinate);
    world.addImport("color", color);

    module.addImport("zigimg", zigimg);
    module.addImport("yaml", yaml);

    glfw_webgpu.addImport("glfw", glfw);
    glfw_webgpu.addImport("webgpu", webgpu);

    graphics.addImport("glfw", glfw);
    graphics.addImport("webgpu", webgpu);
    graphics.addImport("glfw-webgpu", glfw_webgpu);
    graphics.addImport("scene", scene);
    graphics.addImport("color", color);

    gui.addImport("glfw", glfw);
    gui.addImport("webgpu", webgpu);
    gui.addImport("graphics", graphics);

    scene.addImport("algebra", algebra);
    scene.addImport("coordinate", coordinate);
    scene.addImport("color", color);
    scene.addImport("graphics", graphics);

    simulation.addImport("algebra", algebra);
    simulation.addImport("color", color);
    simulation.addImport("coordinate", coordinate);
    simulation.addImport("module", module);
    simulation.addImport("world", world);

    protocol.addImport("color", color);

    client.addImport("glfw", glfw);
    client.addImport("gui", gui);
    client.addImport("color", color);
    client.addImport("graphics", graphics);
    client.addImport("scene", scene);
    client.addImport("protocol", protocol);

    server.addImport("module", module);
    server.addImport("color", color);
    server.addImport("simulation", simulation);
    server.addImport("protocol", protocol);
    
    root.addImport("client", client);
    root.addImport("server", server);

    // TODO do we actually need this?!
    test_root.addImport("algebra", algebra);
    test_root.addImport("coordinate", coordinate);
    test_root.addImport("server", server);
    test_root.addImport("world", world);
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