//! This is the main file of this project, where the game-loop, server and terminal are initialised.
const std = @import("std");
const logex = @import("logex");
const kom = @import("root.zig");
const game = kom.game;
const KommodoServer = @import("util/net/net.zig").KommodoServer;

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

    // Server
    const props = try kom.findOrCreateProperties(alloc);
    // TODO: eig braucht server kein addr übergeben zu bekommen, denn es ist ja in props enthalten

    var server = try KommodoServer.new(alloc, props);
    try server.start();
    defer server.stop();

    //_ = try game.startServer(alloc, props, addr, &running, update);
}

pub fn update() void {
    // var stdout_buffer: [1024]u8 = undefined;
    // const stdout = &stdout_writer.interface;

    // stdout.print("Hello, World!\n", .{}) catch {};
    // _ = stdout.flush() catch {};
}
