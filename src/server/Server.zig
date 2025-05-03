const std = @import("std");
const World = @import("world").World;

const log = std.log.scoped(.server);

const Self = @This();

pub const Error = error {

};

pub fn launch(self: Self) Error!void {
    _ = self;
    log.info("Launching server", .{});
}