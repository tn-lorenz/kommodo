//! This is the main file of this project, where the game-loop, server and terminal are initialised.
const std = @import("std");
const logex = @import("logex");
const kom = @import("root.zig");
const game = kom.game;

var running: std.atomic.Value(bool) = .init(false);

// Logging
const ConsoleAppender = logex.appenders.Console(.debug, .{});
const FileAppender = logex.appenders.File(.info, .{
    .format = .json,
});

const Logger = logex.Logex(.{}, .{ ConsoleAppender, FileAppender });

pub const std_options: std.Options = .{
    .logFn = Logger.logFn,
};

pub fn main() !void {
    // Allocator
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Logging
    const cwd = std.fs.cwd();
    _ = try cwd.makeDir("logs");

    const console_appender = ConsoleAppender.init;
    const file_appender = try FileAppender.init("logs/kommodo.log");
    try Logger.init(.{}, .{ console_appender, file_appender });

    std.log.info("Logger initialised", .{});

    // Arg parsing
    const args = try std.process.argsAlloc(alloc);

    var parser = std.build.ArgParser.init(args[0..]);
    defer parser.deinit();

    // Server
    const props = try kom.findOrCreateProperties(alloc);
    const addr = try std.net.Address.parseIp4(props.host, props.port);

    _ = try game.startServer(alloc, props, addr, &running, update);
}

pub fn update() void {
    // var stdout_buffer: [1024]u8 = undefined;
    // const stdout = &stdout_writer.interface;

    // stdout.print("Hello, World!\n", .{}) catch {};
    // _ = stdout.flush() catch {};
}
