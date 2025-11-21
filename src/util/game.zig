const std = @import("std");
const AtomicOrder = std.builtin.AtomicOrder;
const ThreadCtx = @import("../root.zig").ThreadCtx;

pub fn tick(ctx: *ThreadCtx, foo: ?fn () void) void {
    const interval_ns: u64 = 1_000_000_000 / 20;
    // defer ctx.allocator.destroy(ctx);

    var next = std.time.nanoTimestamp() + interval_ns;

    while (ctx.running.load(.acquire)) {
        const now = std.time.nanoTimestamp();

        var remaining: i64 = @intCast(next - now);
        if (remaining < 0) remaining = 0;

        std.Thread.sleep(@intCast(remaining));

        next += interval_ns;

        if (foo) |cb| {
            cb();
        }
    }
}
