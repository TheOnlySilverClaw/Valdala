const std = @import("std");
const custom_log = @import("log.zig");

pub const std_options = std.Options {
    .logFn = custom_log.pretty
};

pub fn main() !void {

    const client_log = std.log.scoped(.client);
    const server_log = std.log.scoped(.server);

    for(0..3) |i| {
        client_log.debug("Hmm {d}", .{ i });
        client_log.info("Blah {d}", .{ i });
        server_log.debug("Hey! {d}", .{ i });
        client_log.warn("Oh? {d}", .{ i });
        client_log.err("No! {d}", .{ i });
        client_log.debug("meep {d}", .{ i });
    }
}
