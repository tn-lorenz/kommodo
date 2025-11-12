//! This utility combines all the methods necessary for networking interactions.
const std = @import("std");

pub const ConnectionProtocol = enum {
    Tcp,
    Udp,
    Quic,
    Custom,

    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .Tcp => "Tcp",
            .Udp => "Udp",
            .Quic => "Quic",
            .Custom => "Custom",
        };
    }
};

// TODO: actually establish connection
pub fn openConnection(cp: ConnectionProtocol, addr: std.net.Address, port: u16) !void {
    // const stdout = std.fs.File.stdout();
    // try stdout.print("Opening connection via {s} on {s}:{d}\n", .{ @tagName(cp), addr, port });
    _ = cp;
    _ = addr;
    _ = port;
}
