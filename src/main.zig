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

    const server = try Server.init(debug_allocator.allocator(), directory);
    const server_thread = try Thread.spawn(.{ .allocator = server.allocator }, Server.launch, .{ server });

    // client should be on the main thread because operating system restrictions
    const client = try Client.init(debug_allocator.allocator());
    try client.launch();
    
    server_thread.join();
    
    server.deinit();
    client.deinit();

    _ = debug_allocator.deinit();

    log.info("Finished", .{});
}
