const std = @import("std");
const kom = @import("root.zig");
const game = kom.game;

const prefix_log: []const u8 = "[log]:";

var running: std.atomic.Value(bool) = .init(false);

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const props = try kom.findOrCreateProperties(alloc);

    const addr = try std.net.Address.parseIp4(props.host, 0);

    try game.startServer(props, addr, &running, update);
    try game.initLog(prefix_log);
    try game.initInput();
}

pub fn update() void {
    // ...
}
