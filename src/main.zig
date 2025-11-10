const std = @import("std");
const kom = @import("kommodo");
const AtomicOrder = std.builtin.AtomicOrder;

const prefix_log: []const u8 = "[log]:";

var running: std.atomic.Value(bool) = .init(false);

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const props = try kom.findOrCreateProperties(alloc);

    const addr = try std.net.Address.parseIp4(props.host, 0);
    try startServer(props, addr);
}

fn startServer(props: kom.config.Properties, addr: std.net.Address) !void {
    try initLog();
    try startGameLoop();
    try kom.openConnection(props.protocol, addr, props.port);
}

pub fn startGameLoop() !void {
    running.store(true, AtomicOrder.seq_cst);

    _ = try std.Thread.spawn(.{}, thread_function, .{null});
}

fn thread_function(_: ?*anyopaque) void {
    const interval: i128 = 1_000_000_000 / 20;
    var last = std.time.nanoTimestamp();
    var delta: i128 = 0;
    var current: i128 = 0;

    while (running.load(AtomicOrder.seq_cst)) {
        current = std.time.nanoTimestamp();
        delta += @divTrunc(current - last, interval);
        last = current;

        if (delta >= 1) {
            try update();
            delta -= 1;
        }
    }
}

pub fn update() !void {
    // ...
}

fn initLog() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer: std.fs.File.Writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout: *std.Io.Writer = &stdout_writer.interface;

    try stdout.print("{s} Initialised log.", .{prefix_log});

    // Always at the end
    try stdout.flush();
}

pub fn initInput() !void {
    var stdin_buffer: [1024]u8 = undefined;
    const stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    const reader: std.io.Reader = stdin_reader.interface;

    var line_buffer = std.io.Writer.Allocating.init(std.heap.page_allocator);
    defer line_buffer.deinit();

    while (true) {
        line_buffer.writer().clear();
        try std.io.Reader.readUntilDelimiterOrEof(&reader, '\n', &line_buffer.writer());
        const line = line_buffer.written();

        if (line.len == 0) continue;

        var args = std.mem.split(line, " ");

        std.debug.print("Command: {s}\n", .{line});

        if (args.next()) |first| {
            std.debug.print("Command word: {s}\n", .{first});
        }
    }
}
