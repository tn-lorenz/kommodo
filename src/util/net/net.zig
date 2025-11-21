const std = @import("std");
const tcp = @import("tcp.zig");
const config = @import("../config.zig");
const AtomicOrder = std.builtin.AtomicOrder;
const thread_fn = @import("../game.zig").thread_function;
const ThreadCtx = @import("../../root.zig").ThreadCtx;

pub const KommodoServer = struct {
    allocator: std.mem.Allocator,
    address: std.net.Address,
    props: config.Properties,
    running: std.atomic.Value(bool),
    game_thread: ?std.Thread,

    pub fn new(allocator: std.mem.Allocator, props: config.Properties) !KommodoServer {
        // TODO: besseres handling, wenn z.B. props nicht gefunden/lesbar/vollständig
        const addr = try std.net.Address.parseIp4(props.host, props.port);

        return KommodoServer{
            .allocator = allocator,
            .address = addr,
            .props = props,
            .running = std.atomic.Value(bool).init(true),
            .game_thread = null,
        };
    }

    pub fn start(self: *KommodoServer) !void {
        self.running.store(true, .seq_cst);

        const ctx = try self.allocator.create(ThreadCtx);

        ctx.* = ThreadCtx{
            .running = &self.running,
            .allocator = self.allocator,
        };

        self.game_thread = try std.Thread.spawn(.{}, thread_fn, .{ctx});

        try openConnection(self.allocator, self.props.protocol, self.address);
    }

    pub fn stop(self: *KommodoServer) void {
        self.running.store(false, .seq_cst);
        if (self.game_thread) |thread| {
            thread.join();
            self.game_thread = null;
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
    allocator: std.mem.Allocator,
    cp: ConnectionProtocol,
    addr: std.net.Address,
) !void {
    switch (cp) {
        .Tcp => return tcp.startTcpServer(allocator, addr),
        else => return error.UnsupportedProtocol,
    }
}
