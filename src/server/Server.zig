const std = @import("std");
const fs = std.fs;
const log = std.log.scoped(.server);

const Simulation = @import("simulation").Simulation;
const ModuleLoader = @import("module").Loader;


const Allocator = std.mem.Allocator;


pub const Error = error {

};

const Self = @This();

allocator: Allocator,
directory: fs.Dir,
module_loader: *ModuleLoader,
simulation: ?*Simulation,

pub fn init(allocator: Allocator, directory: fs.Dir) !Self {

    const module_loader = try allocator.create(ModuleLoader);
    const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    module_loader.* = try ModuleLoader.init(allocator, module_directory);
    
    return .{
        .allocator = allocator,
        .directory = directory,
        .module_loader = module_loader,
        .simulation = null
    };
}

pub fn deinit(self: Self) void {
    self.allocator.destroy(self.module_loader);
    if(self.simulation) |simulation| {
        simulation.deinit();
        self.allocator.destroy(simulation);
    }
}

pub fn launch(self: *Self) !void {

    log.info("Launching server", .{});

    const simulation = try self.allocator.create(Simulation);
    self.simulation = simulation;
    simulation.* = try Simulation.init(self.allocator);

    const simulation_thread = try std.Thread.spawn(.{ .allocator = self.allocator }, Simulation.start, .{ simulation });
    simulation_thread.join();
}

pub fn shutdown(self: *Self) !void {

    log.info("Shutting down server", .{});
    if(self.simulation) |simulation| {
        simulation.stop();
    }
}