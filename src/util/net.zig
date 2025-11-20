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

pub fn openConnection(
    allocator: std.mem.Allocator,
    cp: ConnectionProtocol,
    addr: std.net.Address,
) !void {
    switch (cp) {
        .Tcp => return startTcpServer(allocator, addr),
        else => return error.UnsupportedProtocol,
    }
}

const ThreadCtx = struct {
    allocator: std.mem.Allocator,
    addr: std.net.Address,
};

pub fn startTcpServer(
    allocator: std.mem.Allocator,
    addr: std.net.Address,
) !void {
    const ctx_ptr = try allocator.create(ThreadCtx);
    ctx_ptr.* = ThreadCtx{
        .allocator = allocator,
        .addr = addr,
    };
    _ = try std.Thread.spawn(.{}, tcpServerThread, .{ctx_ptr});
}

fn tcpServerThread(ctx_ptr: *ThreadCtx) !void {
    const ctx = ctx_ptr.*;
    defer ctx.allocator.destroy(ctx_ptr);

    const listen_options = std.net.Address.ListenOptions{
        .reuse_address = true,
        .kernel_backlog = 128,
        .force_nonblocking = false,
    };

    var server = ctx.addr.listen(listen_options) catch |err| {
        std.debug.print("Failed to listen on {any}: {}\n", .{ ctx.addr, err });
        return;
    };
    defer {
        // server.close(); vllt Connection -> stream schließen?
        server.deinit();
    }

    std.debug.print("Server listening on ", .{});
    try printAddress(ctx.addr);
    std.debug.print(":{d}\n", .{ctx.addr.getPort()});

    while (true) {
        var connection = server.accept() catch |err| {
            std.debug.print("Accept error: {}\n", .{err});
            continue;
        };
        _ = std.Thread.spawn(.{}, handleClient, .{&connection}) catch |err| {
            std.debug.print("Failed to spawn client handler: {}\n", .{err});
        };
    }
}

pub fn handleClient(conn: *std.net.Server.Connection) !void {
    defer conn.stream.close();

    var buf_read: [1024]u8 = undefined;
    var buf_write: [1024]u8 = undefined;

    var writer = std.net.Stream.writer(conn.stream, &buf_write);

    while (true) {
        // const n = try reader.interface().readSliceAll(&buf_read);
        const n = try conn.stream.read(&buf_read);

        if (n == 0) break;
        try writer.interface.writeAll(buf_write[0..n]);
    }
}

fn printAddress(addr: std.net.Address) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try addr.format(stdout);
}
