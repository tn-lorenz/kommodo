const std = @import("std");
const kom = @import("root.zig");
const game = kom.game;

var running: std.atomic.Value(bool) = .init(false);

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    // alternativ: defer std.debug.assert(gpa.deinit() == .ok);

    const alloc = gpa.allocator();
    const props = try kom.findOrCreateProperties(alloc);
    const addr = try std.net.Address.parseIp4(props.host, 0);

    try game.startServer(alloc, props, addr, &running, update);
}

pub fn update() void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    _ = stdout.print("Hello, World!\n", .{}) catch {};
    _ = stdout.flush() catch {};
}
