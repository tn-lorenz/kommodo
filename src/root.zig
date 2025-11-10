const std = @import("std");
pub const config = @import("config/config.zig");

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

pub fn findOrCreateProperties(allocator: std.mem.Allocator) !config.Properties {
    const path = "../properties.json";
    var props: config.Properties = undefined;

    const file = std.fs.cwd().openFile(path, .{}) catch null;
    if (file) |f| {
        defer f.close();
        props = try config.Properties.load(path, allocator);
    } else {
        props = config.Properties.default();
        try config.Properties.save(path, allocator, props);
    }

    return props;
}

pub fn openConnection(cp: ConnectionProtocol, addr: std.net.Address, port: u16) !void {
    std.debug.print("Opening connection via {s} on {any}:{d}\n", .{ cp.toString(), addr, port });
}
