const std = @import("std");
const Build = std.Build;
const Target = std.Target;

const panic = std.debug.panic;


pub fn build(b: *Build) void {

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main_module = b.createModule(.{
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("src/main.zig")
    });

    const test_module = b.createModule(.{
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("src/test.zig")
    });

    organizeModules(b, main_module, test_module, target, optimize);

    const exe = b.addExecutable(.{
        .name = "Valdala",
        .root_module = main_module
    });

    linkLibraries(b, exe, target, optimize);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = test_module
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}


fn organizeModules(b: *std.Build, root: *Build.Module, test_root: *Build.Module, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {

    const build_options = b.addOptions();
    build_options.addOption(bool, "debug_wireframe", b.option( bool, "debug_wireframe", "Enables simplified wireframe terrain shader for debugging.",) orelse false);

    const FastNoiseLite = b.dependency("FastNoiseLite", .{});
    const fastnoise = b.addModule("fastnoise", .{
        .root_source_file = FastNoiseLite.path("Zig/fastnoise.zig"),
        .target = target,
        .optimize = optimize
    });

    const zigimg = b.dependency("zigimg", .{}).module("zigimg");
    const TrueType = b.dependency("TrueType", .{}).module("TrueType");
    const yaml = b.dependency("yaml", .{}).module("yaml");
    const glfw = b.dependency("glfw", .{}).module("glfw");
    const webgpu = b.dependency("webgpu", .{}).module("webgpu");
    const zgltf = b.dependency("zgltf", .{}).module("zgltf");

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

    const terrain = b.addModule("terrain", .{
        .root_source_file = b.path("src/terrain/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const asset = b.addModule("assset", .{
        .root_source_file = b.path("src/asset/module.zig" ),
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

    const game = b.addModule("game", .{
        .root_source_file = b.path("src/game/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    const client = b.addModule("client", .{
        .root_source_file = b.path("src/client/module.zig" ),
        .target = target,
        .optimize = optimize
    });

    coordinate.addImport("algebra", algebra);

    terrain.addImport("algebra", algebra);
    terrain.addImport("coordinate", coordinate);
    terrain.addImport("color", color);
    terrain.addImport("fastnoise", fastnoise);

    asset.addImport("zigimg", zigimg);
    asset.addImport("yaml", yaml);
    asset.addImport("webgpu", webgpu);

    asset.addOptions("build_options", build_options);


    glfw_webgpu.addImport("glfw", glfw);
    glfw_webgpu.addImport("webgpu", webgpu);

    graphics.addImport("glfw", glfw);
    graphics.addImport("webgpu", webgpu);
    graphics.addImport("glfw-webgpu", glfw_webgpu);
    graphics.addImport("scene", scene);
    graphics.addImport("color", color);
    graphics.addImport("asset", asset);
    graphics.addImport("coordinate", coordinate);
    graphics.addImport("algebra", algebra);
    graphics.addImport("module", module);
    graphics.addImport("TrueType", TrueType);
    graphics.addImport("gui", gui);

    module.addImport("zigimg", zigimg);
    module.addImport("yaml", yaml);
    module.addImport("graphics", graphics);
    module.addImport("zgltf", zgltf);

    gui.addImport("glfw", glfw);
    gui.addImport("webgpu", webgpu);
    gui.addImport("graphics", graphics);
    gui.addImport("scene", scene);
    gui.addImport("algebra", algebra);
    gui.addImport("asset", asset);
    gui.addImport("coordinate", coordinate);

    scene.addImport("algebra", algebra);
    scene.addImport("coordinate", coordinate);
    scene.addImport("color", color);
    scene.addImport("graphics", graphics);
    scene.addImport("webgpu", webgpu);
    scene.addImport("terrain", terrain);
    scene.addImport("module", module);

    game.addImport("algebra", algebra);
    game.addImport("color", color);
    game.addImport("coordinate", coordinate);
    game.addImport("module", module);
    game.addImport("terrain", terrain);

    client.addImport("glfw", glfw);
    client.addImport("gui", gui);
    client.addImport("color", color);
    client.addImport("graphics", graphics);
    client.addImport("scene", scene);
    client.addImport("asset", asset);
    client.addImport("module", module);
    client.addImport("terrain", terrain);
    client.addImport("game", game);
    client.addImport("TrueType", TrueType);

    root.addImport("client", client);

    // TODO do we actually need this?!
    test_root.addImport("algebra", algebra);
    test_root.addImport("coordinate", coordinate);
    test_root.addImport("terrain", terrain);
    test_root.addImport("zgltf", zgltf);
}

fn linkLibraries(b: *Build, exe: *Build.Step.Compile, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {

    exe.linkLibC();
    exe.linkSystemLibrary("unwind");

    switch (target.result.os.tag) {
        .linux => {
            exe.addObjectFile(b.path("lib/linux/libglfw3.a"));
            var has_wgpu_native = true;
            std.fs.accessAbsolute(std.Build.pathFromRoot(b,"lib/libwgpu_native.a"), .{}) catch |err| {
                has_wgpu_native = if (err == error.FileNotFound) false else true;
            };
            if (has_wgpu_native) {
                exe.addObjectFile(b.path("lib/libwgpu_native.a"));
            } else {
                if(b.lazyDependency("wgpu_linux", .{})) |wgpu_dep| exe.addObjectFile(wgpu_dep.path("lib/libwgpu_native.a"));
            }
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
            metal_layer_mod.addCSourceFile(.{ .file = b.path("src/glfw-wgpu/metal_layer.m") });

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
