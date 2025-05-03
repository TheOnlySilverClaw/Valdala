const std = @import("std");
const log = std.log.scoped(.main);
const Server = @import("server").Server;

pub const std_options = std.Options {
    .logFn = @import("log.zig").pretty
};

pub fn main() !void {

    log.info("Launching", .{});

    var debug_allocator = std.heap.DebugAllocator(.{}).init;

    const directory = std.fs.cwd();
    const server = try Server.init(debug_allocator.allocator(), directory);
    const server_thread = try std.Thread.spawn(.{ .allocator = server.allocator }, Server.launch, .{ server });
    server_thread.join();
    server.deinit();

    _ = debug_allocator.deinit();

    log.info("Finished", .{});
}
