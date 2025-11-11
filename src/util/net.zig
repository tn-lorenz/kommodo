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

pub fn openConnection(cp: ConnectionProtocol, addr: std.net.Address, port: u16) !void {
    std.debug.print("Opening connection via {s} on {any}:{d}\n", .{ cp.toString(), addr, port });
}
