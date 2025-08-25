const std = @import("std");
const net = std.net;
const fs = std.fs;
const glfw = @import("glfw");
const gui = @import("gui");
const graphics = @import("graphics");
const log = std.log.scoped(.client);

const Allocator = std.mem.Allocator;
const Thread = std.Thread;
const Connection = @import("Connection.zig");
const ModuleLoader = @import("module").Loader;
const World = @import("world").World;
const Scene = @import("scene").Scene;

const Self = @This();


allocator: Allocator,
window: *gui.Window,
controller: *gui.Controller,
renderer: graphics.GameRenderer,
connection: *Connection,
world: *World,
scene: *Scene,
module_loader: ModuleLoader,

pub fn init(allocator: Allocator, directory: fs.Dir) !Self {

    try glfw.initialize();

    const window = try allocator.create(gui.Window);
    window.* = gui.Window.init(allocator);

    const controller= try allocator.create(gui.Controller);
    controller.* = gui.Controller.init(window);
    try controller.registerWindowListeners();

    const monitor = glfw.Monitor.getPrimary() orelse {
        log.err("Could not find primary monitor", .{});
        return error.MonitorUnavailable;
    };

    const video_mode = monitor.getVideoMode() orelse {
        log.err("Could not get video mode", .{});
        return error.VideoModeUnavailable;
    };

    const window_percentage: f32 = 0.6;
    const window_width: u32 = @intFromFloat(window_percentage * @as(f32, @floatFromInt(video_mode.width)));
    const window_height: u32 = @intFromFloat(window_percentage * @as(f32, @floatFromInt(video_mode.height)));
    try window.create(window_width, window_height,"Valdala");
    window.center();

    var tile_textures: graphics.TextureArray = undefined;
    tile_textures.create(8, 8, 64, window.surface.device, .{ .label = .sized("tiles")});

    const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    var module_loader = try ModuleLoader.init(allocator, module_directory, tile_textures);
    const module_id = try allocator.dupe(u8, "valdala");
    _ = try module_loader.loadModule(module_id);

    const renderer = try graphics.GameRenderer.init(allocator, window.surface, module_loader.tile_registry);

    const world = try allocator.create(World);
    const scene = try allocator.create(Scene);

    const connection = try allocator.create(Connection);

    return .{
        .allocator = allocator,
        .window = window,
        .controller = controller,
        .renderer = renderer,
        .connection = connection,
        .world = world,
        .scene = scene,
        .module_loader = module_loader
    };
}

pub fn deinit(self: *Self) void {

    self.window.destroy();
    self.window.deinit();
    self.allocator.destroy(self.window);
    
    self.allocator.destroy(self.controller);
    
    self.renderer.deinit(self.allocator);

    self.allocator.destroy(self.connection);

    self.world.deinit();
    self.allocator.destroy(self.world);

    self.allocator.destroy(self.scene);

    self.module_loader.deinit();

    glfw.terminate();
}

pub fn launch(self: *Self) !void {
    
    const chunk_distance = 8;

    self.world.* = try World.init(self.allocator, 12345678);
    self.scene.* = try Scene.init(self.allocator, chunk_distance, self.renderer.surface.aspect);

    const chunk_mesher = @import("scene").ChunkMesher {
        .device = self.window.surface.device,
        .grid = self.world.grid,
        .tile_registry = self.module_loader.tile_registry
    };

    for(0..chunk_distance) |north| {
        for(0..chunk_distance) |south_east| {
            const chunk_position = @import("world").Chunk.Position.of(@intCast(north), @intCast(south_east), 0);
            const chunk = try self.world.loadChunk(chunk_position);
            const mesh = chunk_mesher.generate(chunk_position, chunk);
            try self.scene.addChunkMesh(chunk_position, mesh);
   
        }
    }

    defer self.scene.deinit();

    self.controller.camera = &self.scene.camera;

    const address = try std.net.Address.parseIp4("127.0.0.1", 4040);
    self.connection.* = Connection.init(self.scene);
    try self.connection.connect(address);
    const connection_thread = try Thread.spawn(.{ .allocator = self.allocator }, Connection.receive, .{ self.connection });
    
    while(!self.window.shouldClose()) {
        glfw.pollEvents();
        // TODO this should propably move into an event handler
        self.scene.camera.aspect = self.window.surface.aspect;
        self.window.update();
        try self.renderer.renderScene(self.scene);
        std.time.sleep(std.time.ns_per_ms * 16);
    }

    self.connection.close() catch |err| log.err("Failed to close connection {}", .{ err });
    connection_thread.join();
}