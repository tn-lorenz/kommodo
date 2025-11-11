const std = @import("std");
pub const config = @import("util/config.zig");
pub const game = @import("util/game.zig");

pub fn findOrCreateProperties(allocator: std.mem.Allocator) !config.Properties {
    const path = "../properties.json";
    var props: config.Properties = undefined;

    const file = std.fs.cwd().openFile(path, .{}) catch null;
    if (file) |f| {
        defer f.close();
        props = try config.Properties.load(path, allocator);
    } else {
        props = config.Properties.default();
        try config.Properties.save(path, allocator, props);
    }

    return props;
}
