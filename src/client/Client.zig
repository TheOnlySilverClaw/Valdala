const std = @import("std");
const net = std.net;
const glfw = @import("glfw");
const gui = @import("gui");
const Scene = @import("scene").Scene;
const graphics = @import("graphics");
const log = std.log.scoped(.client);

const Allocator = std.mem.Allocator;
const Thread = std.Thread;
const Connection = @import("Connection.zig");
const AssetLoader = @import("asset").AssetLoader;

const Self = @This();


allocator: Allocator,
window: *gui.Window,
controller: *gui.Controller,
renderer: *graphics.GameRenderer,
connection: *Connection,
scene: *Scene,
asset_loader: AssetLoader,

pub fn init(allocator: Allocator) !Self {

    try glfw.initialize();

    const window = try allocator.create(gui.Window);
    window.* = gui.Window.init(allocator);

    const controller= try allocator.create(gui.Controller);
    controller.* = gui.Controller.init(window);
    try controller.registerWindowListeners();

    try window.create(1600, 1600, "Valdala");
    window.center();

    var asset_loader = try AssetLoader.init(allocator, window.surface.device,"asset");

    const renderer = try allocator.create(graphics.GameRenderer);
    renderer.* = try graphics.GameRenderer.init(allocator, window.surface, &asset_loader);

    const scene = try allocator.create(Scene);

    const connection = try allocator.create(Connection);

    return .{
        .allocator = allocator,
        .window = window,
        .controller = controller,
        .renderer = renderer,
        .connection = connection,
        .scene = scene,
        .asset_loader = asset_loader
    };
}

pub fn deinit(self: Self) void {

    self.window.destroy();
    self.window.deinit();
    self.allocator.destroy(self.window);
    
    self.allocator.destroy(self.controller);
    
    self.renderer.deinit(self.allocator);
    self.allocator.destroy(self.renderer);

    self.allocator.destroy(self.connection);

    self.allocator.destroy(self.scene);

    self.asset_loader.deinit();

    glfw.terminate();
}

pub fn launch(self: *Self) !void {
    
    self.scene.* = try Scene.init(self.allocator, 1);
    defer self.scene.deinit();

    self.controller.camera = &self.scene.camera;

    const address = try std.net.Address.parseIp4("127.0.0.1", 4040);
    self.connection.* = Connection.init(self.scene);
    try self.connection.connect(address);
    const connection_thread = try Thread.spawn(.{ .allocator = self.allocator }, Connection.receive, .{ self.connection });
    
    while(!self.window.shouldClose()) {
        glfw.pollEvents();
        self.window.update();
        try self.renderer.renderScene(self.scene);
        std.time.sleep(std.time.ns_per_ms * 16);
    }

    self.connection.close() catch |err| log.err("Failed to close connection {}", .{ err });
    connection_thread.join();
}