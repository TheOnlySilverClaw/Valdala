const std = @import("std");
const io = std.io;
const net = std.net;

const Self = @This();

stream: net.Stream,

pub fn connect(address: net.Address) !Self {

    const stream = try net.tcpConnectToAddress(address);
    return .{
        .stream = stream,
    };
}

pub fn close(self: *Self) !void {
    self.stream.close();
}