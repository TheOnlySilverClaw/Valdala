const std = @import("std");
const io = std.io;
const net = std.net;
const color = @import("color");
const protocol = @import("protocol");
const log = std.log.scoped(.connection);

const Header = protocol.client.Header;
const Scene = @import("scene").Scene;

const Self = @This();

stream: net.Stream,
reader: net.Stream.Reader,
writer: net.Stream.Writer,
open: bool,
scene: *Scene,

pub fn init(scene: *Scene) Self {
    return .{
        .stream = undefined,
        .reader = undefined,
        .writer = undefined,
        .open = false,
        .scene = scene
    };
}

pub fn connect(self: *Self, address: net.Address) !void {

    self.stream = try net.tcpConnectToAddress(address);
    self.reader = self.stream.reader();
    self.writer = self.stream.writer();

    try self.writeHeader(.connect);
    self.open = true;
}

pub fn receive(self: *Self) !void {

    while(self.open) {
        
        const header = self.readHeader() catch |err| {
            if(err == error.EndOfStream) {
                log.warn("Lost connection while reading", .{});
                return;
            }
            return err;
        };

        switch (header) {
            .disconnect, .shutdown => try self.close(),
            .sky_color => {
                const value = try self.reader.readStructEndian(color.RGB.Compact, .big);
                log.debug("received sky color {d}", .{ value.blue });
                self.scene.sky_color = value.normalize();
            },
            else => {}
        }
    }
}

pub fn close(self: *Self) !void {

    self.open = false;
    try self.writeHeader(.disconnect);
    self.stream.close();
}

fn readHeader(self: *Self) !protocol.server.Header {
    return try self.reader.readEnum(protocol.server.Header, .big);
}

fn writeHeader(self: *Self, header: protocol.client.Header) !void {
    try self.stream.writer().writeByte(@intFromEnum(header));
}