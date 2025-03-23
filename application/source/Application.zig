const std = @import("std");
const log = std.log;
const glfw = @import("glfw");
const graphics = @import("graphics");

const Allocator = std.mem.Allocator;
const Renderer = graphics.ApplicationRenderer;

const Self = @This();

allocator: Allocator,
renderer: Renderer,


pub fn init(allocator: Allocator) !Self {
    
    log.info("Initialize systems", .{});
    log.debug("Initialize GLFW", .{});

    if(!glfw.initialize()) return error.GLFW;
    log.debug("Successfully initialized GLFW {s} for {s}", .{ glfw.getVersion(), @tagName(glfw.getPlatform()) }); 

    glfw.Window.hint(.ClientApi, glfw.no_api);

    log.debug("Create application renderer", .{});
    var renderer: Renderer = undefined;
    try renderer.init(allocator, 60);

    log.debug("Initialized successfully", .{});

    return .{
        .allocator = allocator,
        .renderer = renderer
    };
}


pub fn deinit(self: *Self) void {
    
    self.renderer.deinit();
    
    glfw.terminate();
}


pub fn launch(self: *Self) !void {

    log.info("Launch", .{});

    log.debug("Start renderer", .{});
    self.renderer.start() catch |err| {
        log.err("Renderer crashed: {}", .{ err });
    };

    log.info("Shutdown", .{});
}