const std = @import("std");
const net = std.net;
const fs = std.fs;
const glfw = @import("glfw");
const gui = @import("gui");
const graphics = @import("graphics");
const asset = @import("asset");
const log = std.log.scoped(.client);

const Allocator = std.mem.Allocator;
const Thread = std.Thread;
const ModuleLoader = @import("module").Loader;
const World = @import("world").World;
const Scene = @import("scene").Scene;
const Game = @import("game").Game;
const TrueType = @import("TrueType");
const Font = graphics.Font;

const Self = @This();

allocator: Allocator,
window: *gui.Window,
controller: *gui.Controller,
module_loader: ModuleLoader,
fonts: []Font,

pub fn init(allocator: Allocator, directory: fs.Dir) !Self {

    try glfw.initialize();

    const window = try allocator.create(gui.Window);
    window.* = gui.Window.init(allocator);

    const controller= try allocator.create(gui.Controller);
    controller.* = gui.Controller.new();
    try controller.registerWindowListeners(window);

    const monitor = glfw.monitor.getPrimaryMonitor() orelse {
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

    const tile_textures = graphics.TextureArray.create(8, 8, 64, window.surface.device, .{ .label = .sized("tiles")});

    const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    var module_loader = try ModuleLoader.init(allocator, module_directory, tile_textures);
    const module_id = try allocator.dupe(u8, "valdala");
    _ = try module_loader.loadModule(module_id);


    const font_source = asset.font.fira_code_regular[0..];
    var font = try Font.init(allocator, window.surface.device, font_source, 70, 255);
    try font.loadASCII();

    const fonts = try allocator.alloc(Font, 1);
    fonts[0] = font;

    return .{
        .allocator = allocator,
        .window = window,
        .controller = controller,
        .module_loader = module_loader,
        .fonts = fonts
    };
}

pub fn deinit(self: *Self) void {

    self.window.destroy();
    self.window.deinit();
    self.allocator.destroy(self.window);
    
    self.allocator.destroy(self.controller);
    
    self.module_loader.deinit();

    for(self.fonts) |*font| {
        font.deinit();
    }
    self.allocator.free(self.fonts);

    glfw.terminate();
}

pub fn launch(self: *Self) !void {
    
    const surface = self.window.surface;

    var game = try Game.init(self.allocator);
    defer game.deinit();
    
    var scene = try Scene.init(self.allocator, 1, surface.aspect);
    defer scene.deinit();
    
    const tile_textures = self.module_loader.tile_registry.texture_array;
    var renderer = try graphics.GameRenderer.init(surface, tile_textures, self.fonts);

    var chunk_mesher = @import("scene").ChunkMesher {
        .device = surface.device,
        .tile_registry = self.module_loader.tile_registry,
        .grid = game.world.grid
    };

    const world_center = @import("world").Chunk.Position {
        .height = 0,
        .north = 0,
        .south_east = 0
    };

    try game.world.loadChunks(world_center, 1);

    var chunks = game.world.chunks.iterator();
    while(chunks.next()) |entry| {
        const position = entry.key_ptr.*;
        const chunk = entry.value_ptr.*;
        if(chunk.visible) {
            const mesh = try chunk_mesher.generate(self.allocator, position, chunk);
            try scene.addChunkMesh(entry.key_ptr.*, mesh);
        }
    }

    var text = gui.Text {
        .font = &self.fonts[0],
        .size = self.fonts[0].height,
        .position = .of(10, 10),
        .color = .of(0, 0, 0, 1),
        .value = "Blah"
    };
    
    const text_mesh = try self.allocator.create(gui.TextMesh);
    text_mesh.* = try gui.TextMesher.generate(self.allocator, surface, &text);
    text.mesh = text_mesh;

    defer self.allocator.destroy(text_mesh);
    defer text.mesh.?.destroy();

    var texts = try std.ArrayListUnmanaged(gui.Text).initCapacity(self.allocator, 1);
    texts.appendAssumeCapacity(text);
    defer texts.clearAndFree(self.allocator);

    const canvas = gui.Canvas {
        .texts = texts
    };

    while(true) {
        
        const input = self.controller.poll();
        if(input.window.close) break;
        
        const player_direction = scene.camera.rotation.rotate(input.movement.direction);
        scene.camera.movePitch(player_direction.x);
        scene.camera.moveRoll(player_direction.y);
        scene.camera.moveYaw(player_direction.z);
        scene.camera.rotatePitch(input.movement.rotation.pitch * 0.1);
        scene.camera.rotateYaw(input.movement.rotation.yaw * 0.1);
        scene.camera.rotateRoll(input.movement.rotation.roll * 0.1);

        try game.tick();
        try renderer.render(scene, canvas);
    }

}