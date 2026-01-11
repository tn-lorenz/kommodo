const std = @import("std");
const Allocator = std.mem.Allocator;

pub const EntityId = u8;
pub const ComponentStore = std.AutoHashMap(u32, []const u8);

pub fn addComponent(id: EntityId, comptime component: type, alloc: Allocator) void {}

pub const Position = struct {
    x: i32,
    y: i32,
    z: i32,
};
