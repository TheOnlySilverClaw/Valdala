const std = @import("std");
const log = std.log;
const fs = std.fs;
const glfw = @import("glfw");
const webgpu = @import("webgpu");
const ui = @import("ui");

const Allocator = std.mem.Allocator;
const Window = @import("Window.zig");
const UserInterface = @import("UserInterface.zig");
const Camera = @import("Camera.zig");
const Scene = @import("Scene.zig");
const FrameRenderer = @import("FrameRenderer.zig");
const TextRenderer = @import("TextRenderer.zig");
const FontTexture = @import("FontTexture.zig");
const TrueType = @import("TrueType");
const Controller = @import("Controller.zig");
const CubeRenderer = @import("CubeRenderer.zig");
const Self = @This();

allocator: Allocator,
window: *Window,

frameRenderer: *FrameRenderer,
textRenderer: *TextRenderer,
cubeRenderer: *CubeRenderer,
fontTexture: *FontTexture,
userInterface: *UserInterface,
trueType: *TrueType,
scene: *Scene,
controller: *Controller,


pub fn init(self: *Self, allocator: Allocator, targetFrameRate: u64) !void {

    var window = try allocator.create(Window);
    try window.create("Valdala", 1600, 1200);

    const surface = &window.surface;

    const camera = try allocator.create(Camera);
    camera.* = Camera.new(std.math.degreesToRadians(120), @floatFromInt(window.surface.width), @floatFromInt(window.surface.height), 1000);
    self.scene = try allocator.create(Scene);
    self.scene.* = try Scene.init(allocator, camera);

    self.allocator = allocator;
    self.window = window;

    self.controller = try allocator.create(Controller);
    self.controller.* = Controller {
        .camera = self.scene.camera,
        .window = self.window
    };
    self.window.controller = self.controller;

    const fontBytes = try fs.cwd().readFileAlloc(allocator, "fonts/FiraCode/FiraCode-Regular.ttf", 1_000_000);
    
    self.trueType = try allocator.create(TrueType);
    self.trueType.* = try TrueType.load(fontBytes);
    
    self.fontTexture = try allocator.create(FontTexture);
    self.fontTexture.* = try FontTexture.init(allocator, window.surface.device, self.trueType, 24, 127);
    try self.fontTexture.loadASCII();
    
    self.textRenderer = try allocator.create(TextRenderer);
    self.textRenderer.* = try TextRenderer.init(allocator, &window.surface, self.fontTexture);

    self.userInterface = try allocator.create(UserInterface);
    self.userInterface.* = try UserInterface.init(allocator, self.scene, window, self.textRenderer);
    
    self.cubeRenderer = try allocator.create(CubeRenderer);
    self.cubeRenderer.* = try CubeRenderer.init(allocator, surface, self.scene.camera);

    self.frameRenderer = try allocator.create(FrameRenderer);
    self.frameRenderer.* = try FrameRenderer.init(allocator, targetFrameRate, surface, self.userInterface, self.cubeRenderer);
}

pub fn deinit(self: *Self) void {

    self.userInterface.deinit();
    self.allocator.destroy(self.userInterface);

    self.window.destroy();
    self.allocator.destroy(self.window);

    self.frameRenderer.deinit();
    self.allocator.destroy(self.frameRenderer);

    self.textRenderer.deinit();
    self.allocator.destroy(self.textRenderer);

    self.allocator.free(self.trueType.ttf_bytes);
    self.allocator.destroy(self.trueType);

    self.allocator.destroy(self.scene.camera);
    self.allocator.destroy(self.scene);

    self.allocator.destroy(self.controller);

    self.allocator.destroy(self.cubeRenderer.pipeline);
    self.allocator.destroy(self.cubeRenderer);
}

pub fn start(self: *Self) !void {


    while(self.window.shouldClose() == false) {
        glfw.pollEvents();
        try self.frameRenderer.render();
    }
}
