const std = @import("std");
const log = std.log.scoped(.main);
const Thread = std.Thread;
const Application = @import("client").Application;

pub const std_options = std.Options {
    .logFn = @import("log.zig").pretty
};

pub fn main() !void {

    log.info("Launching", .{});

    var debug_allocator = std.heap.DebugAllocator(.{}).init;

    const directory = std.fs.cwd();
    const allocator = debug_allocator.allocator();

    // client should be on the main thread because operating system restrictions
    var application = try Application.init(allocator, directory);
    try application.launch();
    
    application.deinit();

    _ = debug_allocator.deinit();

    log.info("Finished", .{});
}
