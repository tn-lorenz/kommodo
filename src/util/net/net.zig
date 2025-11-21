const std = @import("std");
const tcp = @import("tcp.zig");
const config = @import("../config.zig");
const AtomicOrder = std.builtin.AtomicOrder;
const game = @import("../game.zig");
const ThreadCtx = @import("../../root.zig").ThreadCtx;

pub const KommodoServer = struct {
    allocator: std.mem.Allocator,
    address: std.net.Address,
    props: config.Properties,
    running: std.atomic.Value(bool),
    tcp_ready: std.atomic.Value(bool),
    game_thread: ?std.Thread,
    tcp_thread: ?std.Thread,

    pub fn new(allocator: std.mem.Allocator, props: config.Properties) !KommodoServer {
        const addr = try std.net.Address.parseIp4(props.host, props.port);
        return KommodoServer{
            .allocator = allocator,
            .address = addr,
            .props = props,
            .running = std.atomic.Value(bool).init(false),
            .tcp_ready = std.atomic.Value(bool).init(false),
            .game_thread = null,
            .tcp_thread = null,
        };
    }

    pub fn start(self: *KommodoServer) !void {
        self.running.store(true, .seq_cst);

        const ctx = try self.allocator.create(ThreadCtx);
        ctx.* = ThreadCtx{
            .running = &self.running,
            .allocator = self.allocator,
        };

        self.game_thread = try std.Thread.spawn(.{}, game.game_loop, .{ctx});
        self.tcp_thread = try std.Thread.spawn(.{}, tcp.startTcpServer, .{self});
        // try openConnection(self.props.protocol, self);
    }

    pub fn stop(self: *KommodoServer) void {
        self.running.store(false, .seq_cst);

        if (self.game_thread) |t| {
            t.join();
            self.game_thread = null;
        }

        if (self.tcp_thread) |t| {
            t.join();
            self.tcp_thread = null;
        }
    }
};

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

pub fn openConnection(
    cp: ConnectionProtocol,
    server: *KommodoServer,
) !void {
    switch (cp) {
        .Tcp => return tcp.startTcpServer(server),
        else => return error.UnsupportedProtocol,
    }
}
