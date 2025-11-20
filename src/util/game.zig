const std = @import("std");
const config = @import("config.zig");
const net = @import("net.zig");
const AtomicOrder = std.builtin.AtomicOrder;

pub fn startServer(allocator: std.mem.Allocator, props: config.Properties, addr: std.net.Address, running: *std.atomic.Value(bool), update_fn: fn () void) !void {
    try initLog("[kommodo]:");

    const game_thread = try startGameLoop(allocator, running, update_fn);
    defer game_thread.join();

    try net.openConnection(allocator, props.protocol, addr);
}

const ThreadCtx = struct {
    running: *std.atomic.Value(bool),
    update_fn: ?*const fn () void,
    allocator: std.mem.Allocator,
};

pub fn startGameLoop(allocator: std.mem.Allocator, running: *std.atomic.Value(bool), update_fn: fn () void) !std.Thread {
    running.store(true, AtomicOrder.seq_cst);

    const ctx = try allocator.create(ThreadCtx);
    ctx.* = ThreadCtx{
        .running = running,
        .update_fn = &update_fn,
        .allocator = allocator,
    };

    return try std.Thread.spawn(.{}, thread_function, .{ctx});
}

fn thread_function(ctx: *ThreadCtx) void {
    const running = ctx.running;

    const interval: i128 = 1_000_000_000 / 20;
    var last = std.time.nanoTimestamp();
    var delta: i128 = 0;

    while (running.load(AtomicOrder.seq_cst)) {
        const current = std.time.nanoTimestamp();
        delta += @divTrunc(current - last, interval);
        last = current;

        if (delta >= 1) {
            if (ctx.update_fn) |f| f();
            delta -= 1;
        }
    }

    ctx.allocator.destroy(ctx);
}

pub fn initLog(prefix: []const u8) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.fs.File.Writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;

    try stdout.print("{s} Initialised log.\n", .{prefix});

    try stdout.flush();
}

pub fn initInput(allocator: std.mem.Allocator) !void {
    _ = try std.Thread.spawn(.{}, inputThread, .{allocator});
}

fn inputThread(allocator: std.mem.Allocator) void {
    const stdin = std.io.getStdIn();
    var read_buffer: [256]u8 = undefined;
    var reader = stdin.reader(&read_buffer);

    while (true) {
        const line = reader.readUntilDelimiterOrEofAlloc(allocator, '\n') catch continue;
        defer allocator.free(line);

        std.debug.print("Command: {s}\n", .{line});
    }
}
