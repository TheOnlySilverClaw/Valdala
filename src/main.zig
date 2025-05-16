const std = @import("std");
const log = std.log.scoped(.main);
const Thread = std.Thread;
const Server = @import("server").Server;
const Client = @import("client").Client;

pub const std_options = std.Options {
    .logFn = @import("log.zig").pretty
};

pub fn main() !void {

    log.info("Launching", .{});

    var debug_allocator = std.heap.DebugAllocator(.{}).init;

    const directory = std.fs.cwd();
    const allocator = debug_allocator.allocator();

    var server = try allocator.create(Server);
    server.* = try Server.init(allocator, directory);
    const server_thread = try Thread.spawn(.{ .allocator = server.allocator }, Server.launch, .{ server });

    // TODO handle waiting for server availability
    Thread.sleep(std.time.ns_per_s);

    // client should be on the main thread because operating system restrictions
    var client = try Client.init(allocator);
    try client.launch();
    
    try server.shutdown();
    server_thread.join();
    
    server.deinit();
    allocator.destroy(server);
    client.deinit();

    _ = debug_allocator.deinit();

    log.info("Finished", .{});
}
