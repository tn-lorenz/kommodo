const std = @import("std");
const kom = @import("root.zig");
const game = kom.game;

var running: std.atomic.Value(bool) = .init(false);

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const alloc = gpa.allocator();
    const props = try kom.findOrCreateProperties(alloc);
    const addr = try std.net.Address.parseIp4(props.host, 0);

    try game.startServer(props, addr, &running, update);
}

pub fn update() void {
    const stdout = std.fs.File.stdout();
    _ = stdout.writeAll("Hello, World!\n") catch {};
}
