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

const Self = @This();


allocator: Allocator,
window: *gui.Window,
controller: *gui.Controller,
renderer: *graphics.GameRenderer,
connection: *Connection,
scene: *Scene,

pub fn init(allocator: Allocator) !Self {

    try glfw.initialize();

    const window = try allocator.create(gui.Window);
    window.* = gui.Window.init(allocator);

    const controller= try allocator.create(gui.Controller);
    controller.* = gui.Controller.init(window);
    try controller.registerWindowListeners();

    try window.create(1600, 1200, "Valdala");
    window.center();

    const renderer = try allocator.create(graphics.GameRenderer);
    renderer.* = try graphics.GameRenderer.init(allocator, window.surface);

    const scene = try allocator.create(Scene);

    const connection = try allocator.create(Connection);

    return .{
        .allocator = allocator,
        .window = window,
        .controller = controller,
        .renderer = renderer,
        .connection = connection,
        .scene = scene
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

    glfw.terminate();
}

pub fn launch(self: *Self) !void {
    
    self.scene.* = try Scene.init(self.allocator, 2);
    defer self.scene.deinit();

    const address = try std.net.Address.parseIp4("127.0.0.1", 4040);
    self.connection.* = Connection.init(self.scene);
    try self.connection.connect(address);
    const connection_thread = try Thread.spawn(.{ .allocator = self.allocator }, Connection.receive, .{ self.connection });
    
    while(!self.window.shouldClose()) {
        glfw.pollEvents();
        self.window.update();
        try self.renderer.renderScene(self.scene);
    }

    self.connection.close() catch |err| log.err("Failed to close connection {}", .{ err });
    connection_thread.join();
}