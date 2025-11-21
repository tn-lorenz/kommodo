const std = @import("std");
const KommodoServer = @import("net.zig").KommodoServer;
const config = @import("../config.zig");

const TcpListener = struct {
    listener: std.net.TcpListener,

    pub fn accept(self: *TcpListener, allocator: std.mem.Allocator) !std.net.TcpStream {
        return try self.listener.accept(allocator);
    }
};

pub fn startTcpServer(
    allocator: std.mem.Allocator,
    server: *KommodoServer,
) !void {
    const ctx_ptr = try allocator.create(KommodoServer);

    // TODO: besseres handling, wenn z.B. props nicht gefunden/lesbar/vollständig
    const addr = try std.net.Address.parseIp4(server.props.host, server.props.port);

    ctx_ptr.* = KommodoServer{
        .allocator = allocator,
        .address = addr,
        .props = server.props,
        .running = std.atomic.Value(bool).init(true),
        .game_thread = null,
    };

    _ = try std.Thread.spawn(.{}, tcpServerThread, .{ctx_ptr});
}

fn tcpServerThread(ctx_ptr: *KommodoServer) !void {
    const ctx = ctx_ptr.*;
    defer ctx.allocator.destroy(ctx_ptr);

    const listen_options = std.net.Address.ListenOptions{
        .reuse_address = true,
        .kernel_backlog = 128,
        .force_nonblocking = false,
    };

    var server = ctx.address.listen(listen_options) catch |err| {
        std.log.warn("Failed to listen on {f}: ", .{ctx.address});
        std.log.err("{}\n", .{err});
        return;
    };
    defer {
        server.deinit();
    }

    std.log.info("Server listening on {f}\n", .{ctx.address});

    while (true) {
        var connection = server.accept() catch |err| {
            std.log.err("Accept error: {}\n", .{err});
            continue;
        };
        _ = std.Thread.spawn(.{}, handleClient, .{&connection}) catch |err| {
            std.log.err("Failed to spawn client handler: {}\n", .{err});
        };
    }
}

pub fn handleClient(conn: *std.net.Server.Connection) !void {
    defer conn.stream.close();

    var buf_read: [1024]u8 = undefined;
    var buf_write: [1024]u8 = undefined;

    var writer = std.net.Stream.writer(conn.stream, &buf_write);

    while (true) {
        const n = try conn.stream.read(&buf_read);

        if (n == 0) break;
        try writer.interface.writeAll(buf_write[0..n]);
    }
}
