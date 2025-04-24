const std = @import("std");
const time = std.time;
const log = std.log;
const glfw = @import("glfw");
const graphics = @import("graphics");
const scripting = @import("scripting");

const World = @import("world").World;
const Allocator = std.mem.Allocator;
const Renderer = graphics.ApplicationRenderer;

const Self = @This();

allocator: Allocator,
path: [:0]const u8,
renderer: Renderer,
world: ?*World = null,

pub fn init(allocator: Allocator, path: [:0]const u8) !Self {

    log.info("Initialize systems", .{});
    log.debug("Initialize GLFW", .{});

    if(!glfw.initialize()) return error.GLFW;
    log.debug("Successfully initialized GLFW {s} for {s}", .{ glfw.getVersion(), @tagName(glfw.getPlatform()) });

    glfw.Window.hint(.ClientApi, glfw.no_api);

    log.debug("Create application renderer", .{});
    var renderer: Renderer = undefined;
    try renderer.init(allocator, 60);

    log.debug("Initialized successfully", .{});

	const module_path = try std.fs.path.join(allocator, &.{ path, "test"});
	const script_module = try scripting.Module.init(allocator, module_path, "foo.um");
	allocator.free(module_path);
	_ = script_module;

    return .{
        .allocator = allocator,
		.path = path,
        .renderer = renderer
    };
}


pub fn deinit(self: *Self) void {

    self.renderer.deinit();

    if(self.world) |world| {
        world.deinit();
        self.allocator.destroy(world);
    }

    glfw.terminate();
}


pub fn launch(self: *Self) !void {

    log.info("Launch", .{});

    log.debug("Start renderer", .{});
    self.renderer.start() catch |err| {
        log.err("Renderer crashed: {}", .{ err });
    };

    const world = try self.allocator.create(World);
    world.* = try World.init(self.allocator, @intCast(time.microTimestamp()));
    self.world = world;

    log.info("Shutdown", .{});
}
