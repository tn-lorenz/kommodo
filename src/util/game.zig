const std = @import("std");
const config = @import("config.zig");
const net = @import("net.zig");
const AtomicOrder = std.builtin.AtomicOrder;

pub fn startServer(props: config.Properties, addr: std.net.Address, running: *std.atomic.Value(bool), update_fn: fn () void) !void {
    try initLog("[log]:");
    try startGameLoop(running, update_fn);
    try net.openConnection(props.protocol, addr, props.port);
}

const ThreadCtx = struct {
    running: *std.atomic.Value(bool),
    update_fn: ?*const fn () void,
};

fn thread_function(arg: ?*anyopaque) void {
    if (arg == null) return;

    const opaque_ptr = arg.?;
    const ctx: *ThreadCtx = @ptrCast(@alignCast(opaque_ptr));

    const running = ctx.running;

    const interval: i128 = 1_000_000_000 / 20;
    var last = std.time.nanoTimestamp();
    var delta: i128 = 0;

    while (running.load(AtomicOrder.seq_cst)) {
        const current = std.time.nanoTimestamp();
        delta += @divTrunc(current - last, interval);
        last = current;

        if (delta >= 1) {
            if (ctx.update_fn) |f| {
                f();
            }
            delta -= 1;
        }
    }

    std.heap.page_allocator.destroy(ctx);
}

pub fn startGameLoop(running: *std.atomic.Value(bool), update_fn: fn () void) !void {
    running.store(true, AtomicOrder.seq_cst);

    const allocator = std.heap.page_allocator;
    const ctx = try allocator.create(ThreadCtx);
    ctx.* = ThreadCtx{
        .running = running,
        .update_fn = &update_fn,
    };

    _ = try std.Thread.spawn(.{}, thread_function, .{ctx});
}

pub fn initLog(prefix: []const u8) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.fs.File.Writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;

    try stdout.print("{s} Initialised log.", .{prefix});

    // Always at the end
    try stdout.flush();
}

// TODO: Cmd starten und alles anzeigen
pub fn initInput() !void {
    // const stdin = std.fs.getStdIn().reader();
    // var read_buffer: [256]u8 = undefined;
    // var stdin_reader = stdin.reader(&read_buffer);
    // const allocator = std.heap.page_allocator;

    // while (true) {
    //     const line = try std.io.readUntilDelimiterOrEofAlloc(allocator, &stdin, '\n');
    //     defer allocator.free(line);

    //     if (line.len == 0) continue;

    //     var args = std.mem.split(line, " ");
    //     std.debug.print("Command: {s}\n", .{line});

    //     if (args.next()) |first| {
    //         std.debug.print("Command word: {s}\n", .{first});
    //     }
    // }
}
