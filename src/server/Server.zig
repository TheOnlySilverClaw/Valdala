const std = @import("std");
const fs = std.fs;
const net = std.net;
const log = std.log.scoped(.server);

const Thread = std.Thread;
const Simulation = @import("simulation").Simulation;
const ModuleLoader = @import("module").Loader;
const Connector = @import("Connector.zig");
const Loop = @import("Loop.zig");

const Allocator = std.mem.Allocator;


pub const Error = error {

};

const Self = @This();

allocator: Allocator,
connector: *Connector,
directory: fs.Dir,
module_loader: *ModuleLoader,
simulation: *Simulation,
loop: Loop,

pub fn init(allocator: Allocator, directory: fs.Dir) !Self {

    const address = try net.Address.parseIp4("127.0.0.1", 4040);
    const connector = try allocator.create(Connector);
    connector.* = try Connector.init(allocator, address, 8);

    const module_loader = try allocator.create(ModuleLoader);
    // TODO figure out what module patrts to load server-side
    // const module_directory = try directory.openDir("modules", .{.iterate = true, .no_follow = true });
    // module_loader.* = try ModuleLoader.init(allocator, module_directory);
    
    const simulation = try allocator.create(Simulation);
    simulation.* = try Simulation.init(allocator);

    const loop = Loop.init(simulation, connector);

    return .{
        .allocator = allocator,
        .connector = connector,
        .directory = directory,
        .module_loader = module_loader,
        .simulation = simulation,
        .loop = loop
    };
}

pub fn deinit(self: Self) void {

    self.connector.deinit();
    self.allocator.destroy(self.connector);

    self.allocator.destroy(self.module_loader);
    
    self.simulation.deinit();
    self.allocator.destroy(self.simulation);
}

pub fn launch(self: *Self) !void {

    log.info("Launching server", .{});

    const loop_thread = try Thread.spawn(.{ .allocator = self.allocator }, Loop.start, .{ &self.loop });
    const receive_thread = try Thread.spawn(.{ .allocator = self.allocator }, Connector.receive, .{ self.connector });
    
    receive_thread.join();
    loop_thread.join();
}

pub fn shutdown(self: *Self) !void {

    log.info("Shutting down server", .{});

    self.loop.stop();

    try self.connector.close();
}