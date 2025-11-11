const std = @import("std");
const net = @import("net.zig");

pub const Properties = struct {
    host: []const u8,
    port: u16,
    protocol: net.ConnectionProtocol,

    pub fn default() Properties {
        return Properties{
            .host = "127.0.0.1",
            .port = 25565,
            .protocol = .Tcp,
        };
    }

    pub fn load(path: []const u8, allocator: std.mem.Allocator) !Properties {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        var read_buffer: [256]u8 = undefined;
        var file_reader = file.reader(&read_buffer);
        var json_reader = std.json.Reader.init(allocator, &file_reader.interface);
        defer json_reader.deinit();

        const parsed = try std.json.parseFromTokenSource(Properties, allocator, &json_reader, .{});
        defer parsed.deinit();

        const host_copy = try allocator.dupe(u8, parsed.value.host);

        return Properties{
            .host = host_copy,
            .port = parsed.value.port,
            .protocol = parsed.value.protocol,
        };
    }

    pub fn save(path: []const u8, alloc: std.mem.Allocator, props: Properties) !void {
        const file = try std.fs.cwd().createFile(path, .{});
        defer file.close();

        const json_text = try std.fmt.allocPrint(
            alloc,
            "{{\n\t\"host\": \"{s}\",\n\t\"port\": {d},\n\t\"protocol\": \"{s}\"\n}}",
            .{ props.host, props.port, props.protocol.toString() },
        );
        defer alloc.free(json_text);

        try file.writeAll(json_text);
    }
};
