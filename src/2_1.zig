const std = @import("std");

const fs = std.fs;
const mem = std.mem;
const meta = std.meta;
const fmt = std.fmt;
const print = std.debug.print;
const testing = std.testing;

const Direction = enum {
    up,
    down,
    forward
};

const Command = struct {
    direction: Direction,
    distance: u8
};

fn parseCommand(input: []const u8) !?Command {
    var tokens = mem.tokenize(u8, input, " ");

    if (meta.stringToEnum(Direction, tokens.next().?)) |direction| {
        return Command{
            .direction = direction,
            .distance = try fmt.parseInt(u8, tokens.next().?, 10)
        };
    } else {
        return null;
    }

}

test "parseCommand" {
    var cmd = (try parseCommand("up 5")).?;
    var expected = Command{
        .direction = .up,
        .distance = 5
    };
    try std.testing.expect(meta.eql(cmd, expected));
}

pub fn main() !void {
    const dir = fs.cwd();

    const f = try dir.openFile("../resources/2_input.txt", .{});
    defer f.close();

    var buf: [16]u8 = undefined;

    var forward_sum: u32 = 0;
    var depth_sum: u32 = 0;

    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var cmd = (try parseCommand(line)).?;
        switch (cmd.direction) {
            .up => depth_sum -= cmd.distance,
            .down => depth_sum += cmd.distance,
            .forward => forward_sum += cmd.distance
        }
    }

    print("{}\n", .{forward_sum * depth_sum});
}
