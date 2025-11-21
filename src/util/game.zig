const std = @import("std");
const config = @import("config.zig");
const net = @import("net/net.zig");
const AtomicOrder = std.builtin.AtomicOrder;
const ThreadCtx = @import("../root.zig").ThreadCtx;

pub fn game_loop(server_ctx: *ThreadCtx) void {
    const running = server_ctx.running;
    const interval: i128 = 1_000_000_000 / 20;

    var next = std.time.nanoTimestamp() + interval;

    while (running.load(AtomicOrder.seq_cst)) {
        const now = std.time.nanoTimestamp();

        var remaining = next - now;

        if (remaining < 0) {
            remaining = 0;
        }

        std.Thread.sleep(@intCast(remaining));

        next += interval;

        // if (server_ctx.update_fn) |f| f(); only if update logic can differ or some shit
    }

    server_ctx.allocator.destroy(server_ctx);
}
