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
    server: *KommodoServer,
) !void {
    server.address = try std.net.Address.parseIp4(server.props.host, server.props.port);
    server.running.store(true, .seq_cst);

    _ = try std.Thread.spawn(.{}, tcpServerThread, .{server});
}

fn tcpServerThread(server: *KommodoServer) !void {
    const listen_options = std.net.Address.ListenOptions{
        .reuse_address = true,
        .kernel_backlog = 128,
        .force_nonblocking = false,
    };

    var listener = server.address.listen(listen_options) catch |err| {
        std.log.err("Failed to listen on {f}: {}\n", .{ server.address, err });
        return;
    };
    defer listener.deinit();

    std.log.info("Server listening on {f}\n", .{server.address});

    while (server.running.load(.seq_cst)) {
        const conn = listener.accept() catch |err| {
            std.log.err("Accept error: {}\n", .{err});
            continue;
        };

        const conn_ptr = try server.allocator.create(std.net.Server.Connection);
        conn_ptr.* = conn;

        _ = std.Thread.spawn(.{}, handleClient, .{ conn_ptr, server.allocator }) catch |err| {
            std.log.err("Failed to spawn client handler: {}\n", .{err});
            server.allocator.destroy(conn_ptr);
        };
    }
}

pub fn handleClient(conn_ptr: *std.net.Server.Connection, allocator: std.mem.Allocator) !void {
    defer conn_ptr.stream.close();
    defer allocator.destroy(conn_ptr);

    var buf_read: [1024]u8 = undefined;
    var buf_write: [1024]u8 = undefined;

    var writer = std.net.Stream.writer(conn_ptr.stream, &buf_write);

    while (true) {
        const n = try conn_ptr.stream.read(&buf_read);
        if (n == 0) break;
        try writer.interface.writeAll(buf_write[0..n]);
    }
}
