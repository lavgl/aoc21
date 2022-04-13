const std = @import("std");

const fs = std.fs;
const fmt = std.fmt;
const mem = std.mem;
const print = std.debug.print;

var allocator_memory: [2 * 2000 * @sizeOf(u32)]u8 = undefined;

pub fn main() !void {
    const dir = fs.cwd();

    const f = try dir.openFile("../resources/1_input.txt", .{});
    defer f.close();
    
    var allocator = std.heap.FixedBufferAllocator.init(allocator_memory[0..]).allocator();
    var data = std.ArrayList(u32).init(allocator);
    defer data.deinit();

    var buf: [5]u8 = undefined;

    while (try f.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try data.append(try fmt.parseInt(u32, line, 10));
    }

    var count: u32 = 0;
    for (data.items) |depth, index| {
        if (index == 0) continue;

        if (depth > data.items[index - 1]) {
            count += 1;
        }
    }

    print("{}\n", .{count});
}