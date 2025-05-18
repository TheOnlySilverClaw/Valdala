const std = @import("std");
const io = std.io;
const net = std.net;
const protocol = @import("protocol");

const Header = protocol.client.Header;


const Self = @This();

stream: net.Stream,

pub fn init() Self {
    return .{
        .stream = undefined
    };
}

pub fn connect(self: *Self, address: net.Address) !void {

    self.stream = try net.tcpConnectToAddress(address);
    try self.writeHeader(.connect);
}

pub fn close(self: *Self) !void {

    try self.writeHeader(.disconnect);
    self.stream.close();
}

fn writeHeader(self: *Self, header: protocol.client.Header) !void {
    try self.stream.writer().writeByte(@intFromEnum(header));
}