const std = @import("std");
const log = std.log;
const glfw = @import("glfw");

const Allocator = std.mem.Allocator;
const ApplicationRenderer = @import("ApplciationRenderer.zig");

const Self = @This();

allocator: Allocator,
renderer: ApplicationRenderer,


pub fn init(allocator: Allocator) !Self {
    
    log.info("Initialize systems", .{});
    log.debug("Initialize GLFW", .{});

    try glfw.initialize();
    log.debug("Successfully initialized GLFW {s} for {s}", .{ glfw.getVersion(), @tagName(glfw.getPlatform()) }); 

    glfw.windowHint(.ClientApi, glfw.no_api);

    log.debug("Create application renderer", .{});
    const renderer = try ApplicationRenderer.init(allocator);

    log.debug("Initialized successfully", .{});

    return .{
        .allocator = allocator,
        .renderer = renderer
    };
}


pub fn deinit(self: Self) void {
    
    _ = self;
    glfw.terminate();
}


pub fn launch(self: Self) !void {

    log.info("Launch", .{});

    _= self;

    log.info("Shutdown", .{});
}