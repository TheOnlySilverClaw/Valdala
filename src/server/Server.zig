const std = @import("std");
const fs = std.fs;
const net = std.net;
const log = std.log.scoped(.server);

const Thread = std.Thread;
const Simulation = @import("simulation").Simulation;
const ModuleLoader = @import("module").Loader;
const Bouncer = @import("Bouncer.zig");

const Allocator = std.mem.Allocator;


pub const Error = error {

};

const Self = @This();

allocator: Allocator,
bouncer: *Bouncer,
directory: fs.Dir,
module_loader: *ModuleLoader,
simulation: ?*Simulation,

pub fn init(allocator: Allocator, directory: fs.Dir) !Self {

    const address = try net.Address.parseIp4("127.0.0.1", 4040);
    const bouncer = try allocator.create(Bouncer);
    bouncer.* = try Bouncer.init(allocator, address);

    const module_loader = try allocator.create(ModuleLoader);
    const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    module_loader.* = try ModuleLoader.init(allocator, module_directory);
    
    return .{
        .allocator = allocator,
        .bouncer = bouncer,
        .directory = directory,
        .module_loader = module_loader,
        .simulation = null
    };
}

pub fn deinit(self: Self) void {

    self.bouncer.deinit();
    self.allocator.destroy(self.bouncer);

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

    const simulation_thread = try Thread.spawn(.{ .allocator = self.allocator }, Simulation.start, .{ simulation });
    const bouncer_thread = try Thread.spawn(.{ .allocator = self.allocator }, Bouncer.receive, .{ self.bouncer });
    
    bouncer_thread.join();
    simulation_thread.join();
}

pub fn shutdown(self: *Self) !void {

    log.info("Shutting down server", .{});

    try self.bouncer.close();

    if(self.simulation) |simulation| {
        simulation.stop();
    }
}