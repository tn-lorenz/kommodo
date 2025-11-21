const std = @import("std");
const config = @import("config.zig");
const net = @import("net/net.zig");
const AtomicOrder = std.builtin.AtomicOrder;
const ThreadCtx = @import("../root.zig").ThreadCtx;

pub fn thread_function(ctx: *ThreadCtx) void {
    const running = ctx.running;
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

        // if (ctx.update_fn) |f| f(); only if update logic can differ or some shit
    }

    ctx.allocator.destroy(ctx);
}
