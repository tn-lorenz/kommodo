//! This is the main file of this project, where the game-loop, server and terminal are initialised.
const std = @import("std");
const kom = @import("root.zig");
const game = kom.game;

/// Global atomic flag indicating whether the server is currently running.
/// Used to control the main server loop and allow coordinated shutdowns.
var running: std.atomic.Value(bool) = .init(false);

/// Entry point of the program.
///
/// Initializes a debug allocator, loads or creates server properties,
/// parses the host address, and starts the game server.
/// The server will run until `running` is set to `false`.
///
/// Errors during initialization (e.g. missing properties or network issues)
/// will propagate up the call stack.
pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();
    const props = try kom.findOrCreateProperties(alloc);
    const addr = try std.net.Address.parseIp4(props.host, 0);

    try game.startServer(alloc, props, addr, &running, update);
}

/// Periodic update callback executed by the server.
///
/// This function is called each tick (or update cycle) while the server
/// is running. It can be used to perform periodic logic, handle scheduled
/// tasks, or log information to the console.
///
/// Currently, it simply prints "Hello, World!" to standard output.
pub fn update() void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    _ = stdout.print("Hello, World!\n", .{}) catch {};
    _ = stdout.flush() catch {};
}
