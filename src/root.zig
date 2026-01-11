const std = @import("std");
pub const config = @import("util/config.zig");
pub const game = @import("util/game.zig");

pub fn findOrCreateProperties(allocator: std.mem.Allocator) !config.Properties {
    const path = "properties.json";
    // var props: config.Properties = undefined;

    const file = std.fs.cwd().openFile(path, .{}) catch null;
    if (file) |f| {
        defer f.close();
        return try config.Properties.load(path, allocator);
        // defer props.deinit(allocator);
    } else {
        const props = try config.Properties.default(allocator);
        try config.Properties.save(path, allocator, props);
        return props;
    }
}

pub const ThreadCtx = struct {
    running: *std.atomic.Value(bool),
    allocator: std.mem.Allocator,
    // update_fn: ?*const fn () void,
};
