const std = @import("std");
const log = std.log.scoped(.main);
const Server = @import("server").Server;

pub const std_options = std.Options {
    .logFn = @import("log.zig").pretty
};

pub fn main() !void {

    log.info("Launching", .{});

    var debug_allocator = std.heap.DebugAllocator(.{}).init;

    const server_allocator = debug_allocator.allocator();
    const server = Server {};
    const server_thread = try std.Thread.spawn(.{ .allocator = server_allocator }, Server.launch, .{ server });
    server_thread.join();

    log.info("Finished", .{});
}
